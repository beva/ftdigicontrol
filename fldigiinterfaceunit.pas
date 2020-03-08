unit flDigiInterfaceUnit;

{$mode objfpc}{$H+}

{< @abstract(This unit define communcation with fldig.)

Some useful things with this unit:
@preformatted(
7322/tcp  open  unknown
7362/tcp  open  Used for RPC-XML communication with fldigi.

RPC-XML documentation:
fldigi.list                     A:n     Returns the list of methods.
fldigi.name                     s:n     Returns the program name.
fldigi.version_struct           S:n     Returns the program version as a struct.
fldigi.version                  s:n     Returns the program version as a string.
fldigi.name_version             s:n     Returns the program name and version.
fldigi.config_dir               s:n     Returns the name of the configuration
                                        directory.
fldigi.terminate                n:i     Terminates fldigi. ``i'' is bitmask spec-
                                        ifying data to save:
                                        0=options; 1=log; 2=macros.


modem.get_name                  s:n     Returns the name of the current modem.
modem.get_names                 A:n     Returns all modem names.
modem.get_id                    i:n     Returns the ID of the current modem.
modem.get_max_id                i:n     Returns the maximum modem ID number.
modem.set_by_name               s:s     Sets the current modem. Returns old name.
modem.set_by_id                 i:i     Sets the current modem. Returns old ID.
modem.set_carrier               i:i     Sets modem carrier. Returns old carrier.
modem.inc_carrier               i:i     Increments the modem carrier frequency.
                                        Returns the new carrier.
modem.get_carrier               i:n     Returns the modem carrier frequency.
modem.get_afc_search_range      i:n     Returns the modem AFC search range.
modem.set_afc_search_range      i:i     Sets the modem AFC search range.
                                        Returns the old value.
modem.inc_afc_search_range      i:i     Increments the modem AFC search range.
                                        Returns the new value.
modem.get_bandwidth             i:n     Returns the modem bandwidth.
modem.set_bandwidth             i:i     Sets the modem bandwidth.
                                        Returns the old value.
modem.inc_bandwidth             i:i     Increments the modem bandwidth.
                                        Returns the new value.
modem.get_quality               d:n     Returns the modem signal quality in the
                                        range [0:100].
modem.search_up                 n:n     Searches upward in frequency.
modem.search_down               n:n     Searches downward in frequency.
modem.olivia.set_bandwidth      n:i     Sets the Olivia bandwidth.
modem.olivia.get_bandwidth      i:n     Returns the Olivia bandwidth.
modem.olivia.set_tones          n:i     Sets the Olivia tones.
modem.olivia.get_tones          i:n     Returns the Olivia tones.


main.get_status1                s:n     Returns the contents of the 1st status
                                        field (typically s/n).
main.get_status2                s:n     Returns the contents of the 2nd status
                                        field.
main.get_sideband               s:n     [DEPRECATED; use main.get_wf_sideband
                                         and/or rig.get_mode]
main.set_sideband               n:s     [DEPRECATED; use main.set_wf_sideband
                                         and/or rig.set_mode]
main.get_wf_sideband            s:n     Returns the current waterfall sideband.
main.set_wf_sideband            n:s     Sets the waterfall sideband to USB or LSB.
main.get_frequency              d:n     Returns the RF carrier frequency.
main.set_frequency              d:d     Sets the RF carrier frequency.
                                        Returns the old value.
main.inc_frequency              d:d     Increments the RF carrier frequency.
                                        Returns the new value.
main.get_afc                    b:n     Returns the AFC state.
main.set_afc                    b:b     Sets the AFC state.
                                        Returns the old state.
main.toggle_afc                 b:n     Toggles the AFC state.
                                        Returns the new state.
main.get_squelch                b:n     Returns the squelch state.
main.set_squelch                b:b     Sets the squelch state.
                                        Returns the old state.
main.toggle_squelch             b:n     Toggles the squelch state.
                                        Returns the new state.
main.get_squelch_level          d:n     Returns the squelch level.
main.set_squelch_level          d:d     Sets the squelch level.
                                        Returns the old level.
main.inc_squelch_level          d:d     Increments the squelch level.
                                        Returns the new level.
main.get_reverse                b:n     Returns the Reverse Sideband state.
main.set_reverse                b:b     Sets the Reverse Sideband state.
                                        Returns the old state.
main.toggle_reverse             b:n     Toggles the Reverse Sideband state.
                                        Returns the new state.
main.get_lock                   b:n     Returns the Transmit Lock state.
main.set_lock                   b:b     Sets the Transmit Lock state.
                                        Returns the old state.
main.toggle_lock                b:n     Toggles the Transmit Lock state.
                                        Returns the new state.
main.get_rsid                   b:n     Returns the RSID state.
main.set_rsid                   b:b     Sets the RSID state.
                                        Returns the old state.
main.toggle_rsid                b:n     Toggles the RSID state.
                                        Returns the new state.
main.get_trx_status             s:n     Returns transmit/tune/receive status.
main.tx                         n:n     Transmits.
main.tune                       n:n     Tunes.
main.rx                         n:n     Receives.
main.abort                      n:n     Aborts a transmit or tune.
main.get_trx_state              s:n     Returns T/R state.
main.run_macro                  n:i     Runs a macro.
main.get_max_macro_id           i:n     Returns the maximum macro ID number.


rig.set_name                    n:s     Sets the rig name for xmlrpc rig
rig.get_name                    s:n     Returns the rig name previously set via
                                        rig.set_name
rig.set_frequency               d:d     Sets the RF carrier frequency.
                                        Returns the old value.
rig.set_modes                   n:A     Sets the list of available rig modes
rig.set_mode                    n:s     Selects a mode previously added by
                                        rig.set_modes
rig.get_modes                   A:n     Returns the list of available rig modes
rig.get_mode                    s:n     Returns the name of the current tran-
                                        sceiver mode
rig.set_bandwidths              n:A     Sets the list of available rig bandwidths
rig.set_bandwidth               n:s     Selects a bandwidth previously added by
                                        rig.set_bandwidths
rig.get_bandwidth               s:n     Returns the name of the current tran-
                                        sceiver bandwidth
rig.get_bandwidths              A:n     Returns the list of available rig
                                        bandwidths
rig.get_notch                   s:n     Reports a notch filter frequency based on
                                        WF action
rig.set_notch                   n:i     Sets the notch filter position on WF
rig.take_control                n:n     Switches rig control to XML-RPC
rig.release_control             n:n     Switches rig control to previous setting


log.get_frequency               s:n     Returns the Frequency field contents.
log.get_time_on                 s:n     Returns the Time-On field contents.
log.get_time_off                s:n     Returns the Time-Off field contents.
log.get_call                    s:n     Returns the Call field contents.
log.get_name                    s:n     Returns the Name field contents.
log.get_rst_in                  s:n     Returns the RST(r) field contents.
log.get_rst_out                 s:n     Returns the RST(s) field contents.
log.get_serial_number           s:n     Returns the serial number field contents.
log.set_serial_number           n:s     Sets the serial number field contents.
log.get_serial_number_sent      s:n     Returns the serial number (sent) field
                                        contents.
log.get_exchange                s:n     Returns the contest exchange field
                                        contents.
log.set_exchange                n:s     Sets the contest exchange field contents.
log.get_state                   s:n     Returns the State field contents.
log.get_province                s:n     Returns the Province field contents.
log.get_country                 s:n     Returns the Country field contents.
log.get_qth                     s:n     Returns the QTH field contents.
log.get_band                    s:n     Returns the current band name.
log.get_notes                   s:n     Returns the Notes field contents.
log.get_locator                 s:n     Returns the Locator field contents.
log.get_az                      s:n     Returns the AZ field contents.
log.clear                       n:n     Clears the contents of the log fields.
log.set_call                    n:s     Sets the Call field contents.
log.set_name                    n:s     Sets the Name field contents.
log.set_qth                     n:s     Sets the QTH field contents.
log.set_locator                 n:s     Sets the Locator field contents.


text.get_rx_length              i:n     Returns the number of characters in the
                                        RX widget.
text.get_rx                     6:ii    Returns a range of characters
                                        (start, length) from the RX text widget.
text.clear_rx                   n:n     Clears the RX text widget.
text.add_tx                     n:s     Adds a string to the TX text widget.
text.add_tx_bytes               n:6     Adds a byte string to the TX text widget.
text.clear_tx                   n:n     Clears the TX text widget.
rxtx.get_data                   6:n     Returns all RXTX combined data since last
                                        query.
rx.get_data                     6:n     Returns all RX data received since last
                                        query.
tx.get_data                     6:n     Returns all TX data transmitted since
                                        last query.


spot.get_auto                   b:n     Returns the autospotter state.
spot.set_auto                   b:b     Sets the autospotter state.
                                        Returns the old state.
spot.toggle_auto                b:n     Toggles the autospotter state.
                                        Returns the new state.
spot.pskrep.get_count           i:n     Returns the number of callsigns spotted
                                        in the current session.


wefax.state_string              s:n     Returns Wefax engine state (tx and rx)
                                        for information.
wefax.skip_apt                  s:n     Skip APT during Wefax reception
wefax.skip_phasing              s:n     Skip phasing during Wefax reception
wefax.set_tx_abort_flag         s:n     Cancels Wefax image transmission
wefax.end_reception             s:n     End Wefax image reception
wefax.start_manual_reception    s:n     Starts fax image reception in manual mode
wefax.set_adif_log              s:b     Set/reset logging to received/transmit
                                        images to ADIF log file
wefax.set_max_lines             s:i     Set maximum lines for fax image reception
wefax.get_received_file         s:i     Waits for next received fax file,
                                        returns its name with a delay.
                                        Empty string if timeout.
wefax.send_file                 s:si    Send file. returns an empty string if OK
                                        otherwise an error message.
navtex.get_message              s:i     Returns next Navtex/SitorB message with
                                        a max delay in seconds..
                                        Empty string if timeout.
navtex.send_message             s:s     Send a Navtex/SitorB message.
                                        Returns an empty string if OK
                                        otherwise an error message.

The three columns are method name, signature (return_type:argument_types),
and description. Refer to the XML-RPC specification for the meaning of the
signature characters (briefly: n=nil, b=boolean, i=integer, d=double,
s=string, 6=bytes, A=array, S=struct).) }

interface

uses
  Classes, SysUtils, base64, RegExpr, dateutils, fphttpclient, fuzzySearch;

const
  LF = chr(10); //< Linux linefeed

type
  { Record type keeping track of filetransfer information }
  TFileTransferInformation = record
    Filename     : string;   //< Name of file in transfer.
    FileSize     : integer;  //< Size of file in bytes.
    PacketCount  : cardinal; //< How many packets that will be transfered (Calculated)
    SequenceCount: cardinal; //< How many sequences (records) there is in each packet. Last one may be shorter.
    BytesInSeq   : integer;  //< How many bytes maximum transfered in each sequence.
  end;

  { @abstract(Interface to fldigi)

    This class is responsible for all communication with fldigi.
  }
  THTTPClient = class(TFPCustomHTTPClient)
  private
    ListenRXActive : boolean;  //< Flag to activate listening to the fldig RX widget
    LocalRXBuffer  : string;   //< Used for internal RX buffer when read from fldigi
    Stringliste : TStringList; //< Used for temporarerly storage in several function
    procedure ActivateListenRX(Status : boolean);
    function createRPCContent(values : TStringList; method : string) : string;
    function SendRPCMessage(RPCMessage : string) : string;      //< Put on headers
    function extractSingleValue(MethodeName : string) : string; //< Returns the value for method for a single value element
  public
    lastRPCXML : string;                            //< Last generated RPC_XML message
    FTI        : TFileTransferInformation;          //< Information about file transfer
    OwnCallSing: string;                            //< Own call sign. Read from fldigi configuration file during creation.
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
    procedure waitforAck(var Answers : TStringList);//< Returns received acknowledges in passed TStringList.
    function clearTXWidget : string;                //< Clear the fldigi TX widget
    function clearRXWidget : string;                //< Clear the fldigi RX widget
    function fetchCallSign : string;                //< Fetch remote call sign from fldigi
    function fetchModemName : string;               //< Returns fldigi modem in use
    function fetchOwnCallSign : string;             //< Fetch own call sign from fldigi configuration file
    function getMessage(Clear : boolean) : string;  //< Get all new text from fldig RX widget and eventually clear it
    function getTransceiverTXMode : string;         //< Get fldigi TX/RX/Tune status
    function putMessage(Message : string) : string; //< Output Message to fldigi tx widget
    function putRXTag : string;                     //< Output ^r plus a LF to fldigi tx widget
    function setAFC(Mode:boolean) : string;         //< Activate or deactivate Fldigi AFC function
    function getAFC : boolean;                      //< Read Fldigi AFC status
    function Transmitt : string;                    //< Starter sending i fldigi

    property StartListeningRX : boolean read ListenRXActive write ActivateListenRX; //< Enabling periodically reading from RX widget.
  end;

implementation

uses MainUnit;

Constructor THTTPClient.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  Stringliste    := TStringList.Create;
  LocalRXBuffer  := '';
  ListenRXActive := false;
  OwnCallSing    := fetchOwnCallSign;
end;

procedure THTTPClient.ActivateListenRX(Status : boolean);
begin
  LocalRXBuffer  := ''; //< Always reset buffer when this function is called
  ListenRXActive := Status;
end;

procedure THTTPClient.waitforAck(var Answers : TStringList);
var
  StartTime    : TDateTime;
  EndTime      : TDateTime;
  Counter      : integer;
  TextReceived : string; // Used to collect and process received text
  Status       : set of (StartTransfer, StartPacket, EndPacket, EndTransfer); // Statusflag used to control communication
begin
  MainForm.HeaderMemo.Clear;
  TextReceived := '';
  Status       := [];
  StartTime    := Now;
  EndTime      := IncSecond(StartTime,10); // Set to returns after 30 seconds if no information is received.{ TODO 4 -oBent -cFiletransfer : Gjør ventetiden styrbar som parameter, kanskje avhengig av operasjonsmodus. }
  Answers.Clear;
  while now < EndTime do
  begin
    for Counter := 1 to 50 do
    begin
     sleep(20);
    end;
    TextReceived += GetMessage(false);
  end;
  {$ifdef Debug}
    if Status = [] then
      MainForm.HeaderMemo.Append('No header found!')
    else
      MainForm.HeaderMemo.Append('Found header!');
  {$endif}
end;

function THTTPClient.getAFC : boolean;
var
  S : string;
begin
  Result := true;
  S := extractSingleValue('main.get_afc');
  if S = '<i4>0</i4>' then Result := false;
end;

function THTTPClient.setAFC(Mode:boolean) : string;
var
  MyMessage : string;
begin
  Stringliste.Clear;
  if Mode then Stringliste.Append('1') else Stringliste.Append('0');
  MyMessage := createRPCContent(Stringliste,'main.set_afc'); // Returns single value
  Result := SendRPCMessage(MyMessage);
end;

function THTTPClient.extractSingleValue(MethodeName : string) : string;
var
  MyMessage : string;
  Regexp    : TRegExpr;
begin
  Stringliste.Clear;
  Result := 'No Value Found!';
//  Result := ''; // Returns this if nothing found
  Regexp := TRegExpr.Create;
  MyMessage := createRPCContent(Stringliste,MethodeName);
  MyMessage := SendRPCMessage(MyMessage);
  try
    Regexp.Expression := '(.*)(<value>)(.*)(</value>)';
    if Regexp.Exec(MyMessage)then
    begin
      Result := Regexp.Match[3];
    end;
  finally
    Regexp.Free;
  end;
end;

function THTTPClient.fetchModemName : string;
begin
  Result := extractSingleValue('modem.get_name');
end;

function THTTPClient.getTransceiverTXMode : string;
begin
  Result := extractSingleValue('main.get_trx_status');
end;

function THTTPClient.fetchOwnCallSign : string;
var
  MyMessage : string;
  Regexp    : TRegExpr;
begin
  Stringliste.Clear;
  Regexp := TRegExpr.Create;
  try
    MyMessage := createRPCContent(Stringliste,'fldigi.config_dir'); // Returns single value
    MyMessage := SendRPCMessage(MyMessage);
    Regexp.Expression := '(.*)(<value>)(.*)(</value>)'; { TODO 3 -oBent : Bytt til bruk av funksjon. Gir bedre oversikt. }
    if Regexp.Exec(MyMessage) then
    begin
      MyMessage := Regexp.Match[3];
      MyMessage := MyMessage + 'fldigi_def.xml'; // fldigi configuration file
      Stringliste.LoadFromFile(MyMessage);
      Regexp.Expression := '(.*)(<MYCALL>)(.*)(</MYCALL>)';
      if RegExp.Exec(Stringliste.Text)then
      begin
        MyMessage := regexp.Match[3];
      end;
    end;
  finally
    Regexp.Free;
  end;
  Result := MyMessage;
end;

function THTTPClient.createRPCContent(values : TStringList; method : string) : string; // Private function
var
  counter : integer;
begin
  lastRPCXML := '<?xml version="1.0"?>'+LF+
                '<methodCall>'+LF+
                '  <methodName>'+method+'</methodName>'+LF+
                '  <params>'+LF;
  for counter := 0 to values.Count -1 do
  begin
    lastRPCXML += '    <param>'+LF+
                  '      <value>'+values[counter]+'</value>'+LF+
                  '    </param>'+LF;
  end;
  lastRPCXML += '  </params>'+LF+
                '</methodCall>';
  Result := lastRPCXML;
end;

function THTTPClient.clearTXWidget : string;
var
  MyMessage : string;
begin
  Stringliste.Clear;
  MyMessage := createRPCContent(Stringliste,'text.clear_tx');
  Result := SendRPCMessage(MyMessage);
end;

function THTTPClient.clearRXWidget : string;
var
  MyMessage : string;
begin
  Stringliste.Clear;
  MyMessage := createRPCContent(Stringliste,'text.clear_rx');
  Result := SendRPCMessage(MyMessage);
end;

function THTTPClient.GetMessage(Clear : boolean): string;
var
  MyMessage, Response : string;
  RExp                : TRegExpr;
begin
  Stringliste.Clear;
  MyMessage := createRPCContent(Stringliste,'rx.get_data');
  Response  := SendRPCMessage(MyMessage);
  if Clear then // Imidiate delete rx data. Be carefull to use this
  begin
    MyMessage := createRPCContent(Stringliste,'text.clear_rx');
    Result    := SendRPCMessage(MyMessage);
  end;
  RExp := TRegExpr.Create;
  try
    RExp.Expression := '(.*)(<value><base64>)(.*)(</base64></value>)';
    if RExp.Exec(Response) then Response := RExp.Match[3];
  finally
    RExp.Free;
  end;
  { TODO -oBent -cReading : Make robust decoding of messages }
  Result := '';
  if Length(Response) > 0 then Result := DecodeStringBase64(Response);
end;

function THTTPClient.fetchCallSign : string;
begin
  Result := extractSingleValue('log.get_call');
end;

function THTTPClient.PutRXTag : string;
var
  MyMessage : string;
begin
  Stringliste.Clear;
  Stringliste.Append('^r'+LF);
  MyMessage := createRPCContent(Stringliste,'text.add_tx');
  Result    := SendRPCMessage(MyMessage);
end;

function THTTPClient.Transmitt : string;
var
  MyMessage : string;
begin
  Stringliste.Clear;
  MyMessage := createRPCContent(Stringliste,'main.tx');
  Result    := SendRPCMessage(MyMessage);
  sleep(100);
end;

function THTTPClient.SendRPCMessage(RPCMessage : string) : string;
begin
  Self.AddHeader('User-Agent',OwnCallSing);
  Self.AddHeader('Host','localhost');
  Self.AddHeader('Content-Type','text/xml');
  Self.AddHeader('Content-Length',IntToStr(Length(RPCMessage)));
  Result := Self.FormPost('http://localhost:7362',RPCMessage); { TODO 2 -oBent -cInitiate : Denne må justeres til å bli en konfigurerbar parameter. }
end;

function THTTPClient.PutMessage(Message : string) : string;
begin
  Stringliste.Clear;
  Stringliste.Append(Message);
  Result := SendRPCMessage(createRPCContent(Stringliste,'text.add_tx'));
end;

Destructor THTTPClient.Destroy;
begin
  Stringliste.Free;
  inherited Destroy;
end;


end.

