unit fuzzySearch;
{< Fuzzy search is the unit that reckognize and decode received datapackets. The unit is able to handle
   different mistransmision of characters by replacing or shift characters in the string that is
   analyzed, to find combination that tests to true. How many errors or shifts that are allowed are
   controlled by parameters. Thus more errors and shifts allowed, the higher the probabillity is to
   accept a wrong packet.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, RegExpr, Codecs;

const
  LF = Chr(10);                //< Linux linefeed
  FOUND_COM_TRANS_START   = 0; //< Flag marking start of communication
  FOUND_COM_PACKET_START  = 1; //< Flag marking start of packet
  FOUND_COM_TRANS_END     = 2; //< Flag marking end of communication
  FOUND_COM_PACKET_END    = 3; //< Flag marking end of packet
  FOUND_COM_SWITCH_TRANSF = 4; //< Flag marking legal end of each transmission, e.g. "ZZ1ZZ de LA9RT k"
  FOUND_COM_PARTNERS      = 5; //< Flag marking leagal start of each transmission, e.g. "ZZ1ZZ de LA9RT"
  FOUND_COM_RECORD        = 6; //< Flag marking that a data sequence has been found
  BUFFERLENGTH            = 1024; //< Length of internal circular buffer. Indicates maximum linelength. Max length before forced administrative tasks
  COM_TRANS_START   = 'eee eee eee eee (.*) de (.*) eee eee eee eee';                        //< Regular expression to catch start of a communication.
  COM_PACKET_START  = 'eee eee eee eee Packet (.*) of (.*) eee eee eee eee';                 //< Regular expression to catch start of a packet
  COM_TRANS_END     = 'eeee eeee eeee eeee End of Filetransfer de (.*) eeee eeee eeee eeee'; //< Regular expression to catch end of a communication
  COM_PACKET_END    = 'ee ee ee ee End of Packet (.*) of (.*) ee ee ee ee';                  //< Regular expression to catch end of a packet
  COM_SWITCH_TRANSF = 'btu (.*) de (.*) k';                                                  //< Regular expression to catch legal end of each transmission
  COM_PARTNERS      = '(.*) de (.*)';                                                        //< Regular expression to catch legal header for each transmission
  COM_RECORD        = '([acdefhilmnoprstu]{16})\ ([acdefhilmnoprstu]{2,})\ ([acdefhilmnoprstu]{8})'; //< Regular expression to catch a data sequence line


type
  { This set og flags keeps track of the communication states.
    @unorderedList(
      @item(fTransStart tells that a start of communication has been received or started.)
      @item(fPacketHeader tells if the formal HAM packet header, <remote call> de <local call> is identified in last detection.)
      @item(fPacketStart tells that a packet header has been received or started.)
      @item(fTransEnd tells that the transmission is complete, except for possible retransmissions.)
      @item(PacketEnd...)
      @item(fSwithcTransf...)
      @item(fPartners tells if remote identifier is identified. In that case that identifier will be used for the duration of transmission.)
      @item(fRecord...)
    )}
  TStateFlags = set of (fTransStart,fPacketHeader,fPacketStart,fTransEnd,fPacketEnd,fSwithcTransf,fPartners,fRecord);
  TBuffer     = array [1..BUFFERLENGTH] of char; //< Circular buffer. Note that it runs from 1.
  pBuffer     = ^TBuffer;
  TTrigInfo   = record //< Type for carrying found information when a match trigg. Use may vary and some elements may be redundant in different cases.
    TriggerCode : integer;
    Info1       : string;
    Info2       : string;
    PackNr      : cardinal; //< 32 bit integer is used for this parameter
    SeqNr       : cardinal; //< 32 bit integer is used for this parameter
    Number1     : integer;
    Number2     : integer;
    Number3     : integer;
  end;

  TTriggMatchEvent = procedure(MatchStatus: TTrigInfo) of Object; //< Carry information when triggered

  TFuzzSearch = class
  private
    Buffer : TBuffer;
    BufferZeroPosition : integer;         //< Points to the first character in buffer
    BufferNowPosition  : integer;         //< Points to the last active character in buffer
    StateFlags         : TStateFlags;
    FOnTriggMatch      : TTriggMatchEvent;
    procedure FuncAddChar(C : char);              //< Adds a character to the buffer.
    procedure FuncAddString(S : string);          //< Adds a string to the buffer.
    procedure ReduceBuffer(NewPosition: integer); //< Reduce buffer when a match is found taking into account possible wrapping of buffer
    function readBufferUseSize : integer;         //< Returns length of used, not treated buffer.
    function ActiveDataAsString : string;         //< Returns the active data in buffer as a string taking into account possible wrapping of buffer.
  public
    LocalCall  : string; //< Local copy of call sign
    RemoteCall : string; //< Local copy of call sign
    constructor Create;    //< Initalize object.
    destructor Free;
    procedure ResetBuffer;  //< Initalize buffer and nullify any data stored.
    { This function try to match the searchString to the received textString allowing for given
      misses and jitter. When match is found, the correspondign buffer will be released and the
      result returned.
      @param(searchString This string is the reference string the search try to find.)
      @param(textString This is the received text string where the function try to correlate the search string.)
      @param(Misses This parameter tells how many misses should be tollerated, and still give a positive match.)
      @param(Jitter This tells how many left and right shifts are tolerated to handle extra or missing character due to noise.)
      @returns(Returns position of the first character in textString matching the searchString. If not found, returns 0 @(zero@).)}
    function foundFuzzyMatch(Misses:integer; Jitter:integer): boolean;
    property AddChar     : char write FuncAddChar;         //< Adds a character to the buffer.
    property AddString   : string write FuncAddString;     //< Adds a string to the buffer. Not optimized, however functional and probably fast enough.
    property Buffertext  : string read ActiveDataAsString; //< The active buffer as a string.
    property LastStatus  : TstateFlags read StateFlags;    //< Flags for last matched result.
    property UsedBuffer  : integer read readBufferUseSize; //< Returns the size of unintepreted buffer. Read only.
    property OnTriggMatch: TTriggMatchEvent read FOnTriggMatch write FOnTriggMatch; // Should trig when a match is found
  end;

implementation

constructor TFuzzSearch.Create;
begin
  inherited Create;
  BufferZeroPosition := 1; // Buffer starts on 1 and runs up to BUFFERLENGTH included
  BufferNowPosition  := 1;
  StateFlags         := [];
end;

destructor TFuzzSearch.Free;
begin
  // Do own stuff, then
  inherited Destroy;
end;

procedure TFuzzSearch.ReduceBuffer(NewPosition: integer);
begin
  If (NewPosition + BufferZeroPosition - 1) > BUFFERLENGTH then
    BufferZeroPosition := BufferZeroPosition + NewPosition - 1 - BUFFERLENGTH
  else
    BufferZeroPosition := BufferZeroPosition + NewPosition - 1;
end;

function TFuzzSearch.foundFuzzyMatch(Misses:integer; Jitter:integer): boolean;
var
  searchCounter, textCounter : integer;
  searchSize,    textSize    : integer;
  DecodedInfo                : TDecodedInfo;
  ActiveData                 : string;
  RegExpr                    : TRegExpr;
  TrigInfo                   : TTrigInfo;
begin
  Result := false;
  ActiveData := ActiveDataAsString;
  RegExpr := TRegExpr.Create;
  try
    // Start of a communication.
    RegExpr.Expression := COM_TRANS_START;
    if RegExpr.Exec(ActiveData) then
    begin
      TrigInfo.TriggerCode := FOUND_COM_TRANS_START;
      RemoteCall     := RegExpr.Match[2];
      LocalCall      := RegExpr.Match[1];
      TrigInfo.Info1 := RegExpr.Match[1]; // NB!!!! Skal være 2 når en mottar fil. Bruker 1 i forbindelse med testfil.
      TrigInfo.Info2 := 'Remote station identified.'; { TODO : Dette må sjekkes litt nøyere, men greit mens jeg tester. }
      TrigInfo.Number1 := RegExpr.MatchPos[0]; // For testing. Indeks null er hele det regulære utrykket
      TrigInfo.Number2 := UsedBuffer;          // For testing.
      TrigInfo.Number3 := RegExpr.MatchLen[0]; // For testing.
      ReduceBuffer(RegExpr.MatchPos[0] + RegExpr.MatchLen[0]);
      StateFlags := [fTransStart,fPartners];
      Result := true;
    end;

    // HAM formal packet header <remote call> de <local call>. No info returned to main program
    if [fTransStart,fPartners] <= StateFlags then
    begin
      RegExpr.Expression := COM_PARTNERS;
      if RegExpr.Exec(ActiveData) then
      begin
        if (RemoteCall = RegExpr.Match[2]) and (LocalCall = RegExpr.Match[1]) then
          StateFlags += [fPacketHeader]
        else
          StateFlags -= [fPacketHeader];
        ReduceBuffer(RegExpr.MatchPos[0] + RegExpr.MatchLen[0]);
      end;
    end;

    // Packet start header, only to be received after a formal HAM header, otherwise invalid.
    if [fPacketHeader] <= StateFlags then
    begin
      RegExpr.Expression := COM_PACKET_START;
      if RegExpr.Exec(ActiveData) then
      begin
        TrigInfo.TriggerCode := FOUND_COM_PACKET_START;
        TrigInfo.Number1     := StrToInt(RegExpr.Match[1]); // Start header packet number
        TrigInfo.Number2     := StrToInt(RegExpr.Match[2]); // Start header total number of packets
        ReduceBuffer(RegExpr.MatchPos[0] + RegExpr.MatchLen[0]);
        StateFlags -= [fPacketHeader];
        Result := true;
      end;
    end;

    // Data sequence line
    RegExpr.Expression := COM_RECORD;
    if RegExpr.Exec(ActiveData) then
    begin
      TrigInfo.TriggerCode := FOUND_COM_RECORD;
      DecodedInfo     := decodePSKSequenceLine(RegExpr.Match[1] + ' ' + RegExpr.Match[2] + ' ' + RegExpr.Match[3]);
      TrigInfo.Info1  := DecodedInfo.DecodedString;
      TrigInfo.PackNr := DecodedInfo.PacketNumber;
      TrigInfo.SeqNr  := DecodedInfo.SequenceNumber;
      TrigInfo.Number1 := RegExpr.MatchPos[0]; // For testing. Indeks null er hele det regulære utrykket
      TrigInfo.Number2 := UsedBuffer;          // For testing.
      TrigInfo.Number3 := RegExpr.MatchLen[0];
      { TODO : Not complete yet }
      ReduceBuffer(RegExpr.MatchPos[0] + RegExpr.MatchLen[0]);
      StateFlags -= [fPacketHeader];
      Result := true;
    end;

  finally
    RegExpr.Free;
  end;
  if Result then
  begin
    if Assigned(FOnTriggMatch) then FOnTriggMatch(TrigInfo); // If match update info
  end;

end;

procedure TFuzzSearch.ResetBuffer;
begin
  BufferZeroPosition := 1; // Buffer starts on 1 and runs uo to BUFFERLENGTH included
  BufferNowPosition  := 1;
end;

procedure TFuzzSearch.FuncAddChar(C : char);
begin
  Buffer[BufferNowPosition] := C;
  Inc(BufferNowPosition);
  if BufferNowPosition > BUFFERLENGTH then BufferNowPosition := 1;
end;

procedure TFuzzSearch.FuncAddString(S : string);
var
  I : integer;
begin
  for I := 1 to Length(S) do
  begin
    FuncAddChar(S[I]);
  end;
end;

function TFuzzSearch.ActiveDataAsString : string;
var
  S : string = '';
  T : string = '';
  I : integer = 0;
begin
  if BufferNowPosition >= BufferZeroPosition then
  begin
    I := BufferNowPosition - BufferZeroPosition; // Length of active buffer and no circular wrapping
    SetString(S, PChar(@Buffer[BufferZeroPosition]), I);
  end
  else
  begin
    I := BUFFERLENGTH - BufferZeroPosition + 1; // First part length of active buffer and circular wrapping
    SetString(S, PChar(@Buffer[BufferZeroPosition]), I);
    I := BufferNowPosition - 1;                 // Second part length of active buffer and circular wrapping
    if I > 0 then SetString(T, PChar(@Buffer[BufferNowPosition - 1]), I) else T := '';
    S += T;
  end;
  Result := S;
end;

function TFuzzSearch.readBufferUseSize : integer;
var
  I : integer = 0;
begin
  if BufferNowPosition >= BufferZeroPosition
  then I := BufferNowPosition - BufferZeroPosition
  else I := BufferNowPosition + BUFFERLENGTH - BufferZeroPosition;
  Result := I;
end;

end.

