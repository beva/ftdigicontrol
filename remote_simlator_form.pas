unit remote_simlator_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TRemote_station_simulator_Form }

  TRemote_station_simulator_Form = class(TForm)
    Simulator_Response_Memo : TMemo;
    Simulator_Encoded_Memo : TMemo;
    Simulator_Decoded_Memo : TMemo;
    Simulator_Receive_Memo : TMemo;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Remote_station_simulator_Form: TRemote_station_simulator_Form;

implementation

{$R *.lfm}

{ TRemote_station_simulator_Form }

procedure TRemote_station_simulator_Form.FormCreate(Sender: TObject);
begin
    Self.Visible := false; // Change this to false later on
end;

end.

