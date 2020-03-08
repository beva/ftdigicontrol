unit Codecs;

{$mode objfpc}{$H+}

(*< @abstract(Unit containing all specialized codecs used. Base64 is handled by freepascal.)

  The ASCII alphabet is shown below, starting with NUL and ending with DEL. Beside you find
  the PSK31 representation. As you can see, the length is varying, with the shortest for the
  most used letters. Those shortest representations are chosen to define HEX codes, thus
  shorten the representation length for these combinations. The intention is to create the
  fastest possible transmission code.

@preformatted(Let PSK31       Hex     Let PSK31       Hex    Let PSK31       Hex   Let PSK31       Hex

NUL 1010101011          SP  1                  @   1010111101        `   1011011111
SOH 1011011011          !   111111111          A   1111101           a   1011        a
STX 1011101101          "   101011111          B   11101011          b   1011111
ETX 1101110111          #   111110101          C   10101101          c   101111      c
EOT 1011101011          $   111011011          D   10110101          d   101101      d
ENQ 1101011111          %   1011010101         E   1110111           e   11          e
ACK 1011101111          &   1010111011         F   11011011          f   111101      f
BEL 1011111101          '   101111111          G   11111101          g   1011011
BS  1011111111          @(   11111011           H   101010101         h   101011      b
HT  11101111            @)   11110111           I   1111111           i   1101        4
LF  11101               *   101101111          J   111111101         j   111101011
VT  1101101111          +   111011111          K   101111101         k   10111111
FF  1011011101          ,   1110101            L   11010111          l   11011       1
CR  11111               -   110101             M   10111011          m   111011      8
SO  1101110101          .   1010111            N   11011101          n   1111        9
SI  1110101011          /   110101111          O   10101011          o   111         0
DLE 1011110111          0   10110111           P   11010101          p   111111      7
DC1 1011110101          1   10111101           Q   111011101         q   110111111
DC2 1110101101          2   11101101           R   10101111          r   10101       3
DC3 1110101111          3   11111111           S   1101111           s   10111       6
DC4 1101011011          4   101110111          T   1101101           t   101         2
NAK 1101101011          5   101011011          U   101010111         u   110111      5
SYN 1101101101          6   101101011          V   110110101         v   1111011
ETB 1101010111          7   110101101          W   101011101         w   1101011
CAN 1101111011          8   110101011          X   101110101         x   11011111
EM  1101111101          9   110110111          Y   101111011         y   1011101
SUB 1110110111          :   11110101           Z   1010101101        z   111010101
ESC 1101010101          ;   110111101          [   111110111         {   1010110111
FS  1101011101          <   111101101          \   111101111         |   110111011
GS  1110111011          =   1010101            ]   111111011         }   1010110101
RS  1011111011          >   111010111          ^   1010111111        ~   1011010111
US  1101111111          ?   1010101111         _   101101101         DEL 1110110101)


Format of packet, when formatted with special encoding of bytes:

@preformatted(    ppppppppssssssss dd....dd ccccccccLF

  where:

    pppppppp : Is packet number, spesial encoded.
    ssssssss : Is Sequence number in packet, special encoded.
    dd....dd : Is the datapacket special encoded. May represent 32 bytes or something else.
    cccccccc : Is CRC32 cheksum, special encoded.
    LF       : Is the Linefeed code @(chr@(10@)@).
    ' '      : Is literal separator, and is just a space @(SP@).)

The CRC code is calculated using the hole line from start to the last 'dd'. Note that one
space is included in this calculation. An encoded line may look like, not showing the line feed:

@preformatted(    oooooooloooooooi prpusisftoslpopitdslsisitdptsupo icldnipi)

which look as this, in standar hex coding:

@preformatted(    0000000100000004 7375646F206170742D6164642D726570 4C1D9474)

Packet number 0 (Zero) defines that the sequence number is encoded with a functional
code, enabling a wast potensial for extending functionallity.

Something nice to know is that the operation 'shl 2' is the same as multiply by 2,
and similar is 'shr 2' the same as divied by 2. I use this in the code to handle
some bit manipulations.

Further on it is notable that the '^cardinal' points to the least significant byte,
and an increment of the pointer point to next more siginificant byte.
*)
interface

uses
  Classes, SysUtils, crc, RegExpr;

const
  PSKencodingtable : array[0..15] of char = ('o','l','t','r','i','u','s','p',
                                             'm','n','a','h','c','d','e','f'); //< Modified and optimized HEX coding for PSK
  PSKENCLENGTH    = 64; //< Default encoded payload length (Twice the number of bytes encoded)
  PACKETSIZE      = 16; //< Default number of sequences in a packet
  REGEXP_SEQUENCE    = '([acdefhilmnoprstu]{16})\ ([acdefhilmnoprstu]{2,})\ ([acdefhilmnoprstu]{8})(.*)'; //< To isolate parts of a sequence line.
  REGEXP_START_TRANS = 'eee eee eee';    //< Mark the start of a packet. Is repeated twice, before and after count information.
  REGEXP_END_PACKET  = 'ee ee ee';       //< Mark the end of a packet. Is repeated twice, before and after count information, except for last packet.
  REGEXP_END_TRANS   = 'eeee eeee eeee'; //< Marks last packet sent.

  FLTYPE_FILETRANSFER =    0; //< Defines a filetransfer operation and carry some metainformation.
  FLTYPE_ACKNOWLEDGE  =    1; //< Acknowledge the hole transmission and may carry some usefull free or formatted text.
  FLTYPE_ACK_SEQUENCE =    2; //< Acknowledge specifically one sequence. Will carry specification of which.
  FLTYPE_ACK_PACKET   =    3; //< Acknowledge a hole packet. Will carry specifiaction of which.
  FLTYPE_MSGID        =  100; //< Payload should be a unique message ID. Reserved for future use for handling multiple simultaniously transmissions.
  FLTYPE_EMAIL        =  200; //< Payload is a complete MIME encoded e-mail. Reserved for future use as e-mail transfer possibillity.

type
  TDecodedInfo = record
    PacketNumber   : cardinal; //< Explisit use 32 bit double word.
    SequenceNumber : cardinal; //< Explisit use 32 bit double word.
    Status         : boolean;  //< Set to true if sequence line pass test and is decoded.
    CRC32          : cardinal; //< CRC32 decoded.
    CR32test       : cardinal; //< CRC32 encoded from decoded sequence line.
    DecodedString  : string;   //< Decoded body part of sequence line.
    ErrorText      : string;   //< Should give a descriptive message if Status is false.
  end;

procedure encodePSKSpecialText(Message: string; Liste: TStringList; PackSize, SeqSize: cardinal); //< PSK encode and format string in multiple lines
function decodePSKSequenceLine(SequenceLine : string) : TDecodedInfo; //< Decode a sequence line and return a record containing the information
function deformatPSKCodedCardinal(Cardstr : string) : cardinal;       //< Decoding of PSK encoded CRC32 checksum
function deformatPSKCodedDatastring(Datastring : string) : string;    //< Decoding of PSK encoded datapacket
function formatPSKCodedCardinal(Number : cardinal) : string;          //< PSK encode a CRC32 hash code
function formatPSKSingleLine(Message: string; Packnr, Seqnr: cardinal) : string; //< Format a single text (byte sequence) line, including CRC32 hash

implementation

function formatPSKSingleLine(Message: string; Packnr, Seqnr: cardinal) : string;
var
  HighB, LowB : Byte;
  Counter     : integer;
  C32         : cardinal;
  Pointer     : ^Byte;
  Symbol      : Char;
begin
  Result := formatPSKCodedCardinal(Packnr) + formatPSKCodedCardinal(Seqnr) + ' ';
  for Counter := 1 to Length(Message) do
  begin
    Symbol  := Message[counter];
    HighB   := (byte(Symbol) and $f0) shr 4;
    LowB    := byte(Symbol) and $0f;
    Result += PSKencodingtable[HighB];
    Result += PSKencodingtable[LowB];
  end;
  Pointer := @Result[1];
  C32 := crc32(0, nil, 0); // Initiates variable before use
  C32 := crc32(C32, Pointer, Length(Result));
  Result += ' ' + formatPSKCodedCardinal(C32);
end;

function deformatPSKCodedCardinal(Cardstr : string) : cardinal;
var
  Counter     : integer;
  HighB, LowB : Byte;
  TempCard    : cardinal;
begin
  TempCard := 0;
  for Counter := 1 to 4 do
  begin
    Tempcard := TempCard shl 8;
    HighB  := Byte(Pos(Copy(Cardstr,Counter*2-1,1),PSKencodingtable) - 1) shl 4;
    LowB   := Pos(Copy(Cardstr,Counter*2,1),PSKencodingtable) - 1;
    TempCard += HighB + LowB;
  end;
  Result := TempCard;
end;

function deformatPSKCodedDatastring(Datastring : string) : string;
var
  Tempstr : string;
  counter : integer;
  AByte   : Byte = 0; // Just to get rid of a warning og unitilized variable
begin
  Tempstr := '';
  for counter := 1 to Length(Datastring)do
  begin
    if (counter mod 2) <> 0 then
      AByte := Byte(Pos(Datastring[counter],PSKencodingtable)-1) shl 4
    else
    begin
      AByte += Byte(Pos(Datastring[counter],PSKencodingtable)-1);
      Tempstr += Char(AByte);
    end;
  end;
  Result := Tempstr;
end;

function decodePSKSequenceLine(SequenceLine : string) : TDecodedInfo;
var
  RegExp : TRegExpr;
  Packetstr, Seqstr, Datastr, CRCstr, teststring : string;
  Pointer  : ^Byte;
  C32      : cardinal;
begin
  Result.Status         := false; // Set default values
  Result.PacketNumber   := 0;
  Result.SequenceNumber := 0;
  Result.CRC32          := 0;
  Result.DecodedString  := '';
  RegExp := TRegExpr.Create;
  try
    RegExp.Expression := REGEXP_SEQUENCE;
    if RegExp.Exec(SequenceLine) then // Then I know the format is acceptable
    begin
      Packetstr := Copy(RegExp.Match[1],1,8);
      Seqstr    := Copy(RegExp.Match[1],9,8);
      Datastr   := RegExp.Match[2];
      CRCstr    := RegExp.Match[3];
      Result.CRC32 := deformatPSKCodedCardinal(CRCstr);
      teststring := Packetstr + Seqstr + ' ' + Datastr;
      Pointer := @teststring[1];
      C32 := crc32(0, nil, 0);
      C32 := crc32(C32, Pointer, Length(teststring));
      if C32 = Result.CRC32 then
      begin
        Result.Status         := true; // CRC32 match
        Result.PacketNumber   := deformatPSKCodedCardinal(Packetstr);
        Result.SequenceNumber := deformatPSKCodedCardinal(Seqstr);
        Result.DecodedString  := deformatPSKCodedDatastring(Datastr);
      end;
    end;
  finally
    RegExp.Free;
  end;
end;

function formatPSKCodedCardinal(Number : cardinal) : string;
var
  HighB, LowB  : Byte;
  Pointer      : ^Byte;
  counter      : integer;
begin
  Result  := '';
  Pointer := @Number;
  Pointer += 3;
  for counter := 1 to 4 do
  begin
    HighB := Pointer^ shr 4;
    LowB  := Pointer^ and $0f;
    Result += PSKencodingtable[HighB] + PSKencodingtable[LowB];
    dec(Pointer);
  end;
end;

procedure encodePSKSpecialText(Message: string; Liste: TStringList; PackSize, SeqSize: cardinal);
var
  counter       : integer;
  teststring    : string;
  PacketCount   : cardinal;
  SequenceCount : cardinal;
  CountOfSeq    : integer;
begin
  Liste.Clear;
  teststring    := '';
  PacketCount   := 1;
  SequenceCount := 1;
  CountOfSeq    := Length(Message) div SeqSize;
  if (Length(Message) mod SeqSize) > 0 then Inc(CountOfSeq);

  repeat
    begin
      counter    := (PacketCount-1)*SeqSize*PackSize + (SequenceCount-1)*SeqSize + 1;
      teststring := Copy(Message,counter,SeqSize);
      Liste.Append(formatPSKSingleLine(teststring,PacketCount,SequenceCount));
      Inc(SequenceCount);
      if SequenceCount > PackSize then
      begin
        SequenceCount := 1;
        Inc(PacketCount);
      end;
//      counter := (PacketCount-1)*SeqSize*PackSize + SequenceCount*SeqSize;
      counter += Length(teststring);
    end;
  until counter >= Length(Message);
end;

end.

