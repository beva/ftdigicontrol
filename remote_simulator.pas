unit remote_simulator;
{< This unist is used to simulate a remote station. Its primary use is to be a helper
   during developement. It is set up as self sustained thread.

   This simulator opens a frame showing different aspects in the communication, which
   are handled by events.

}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
TRemoteStationSimulator= class(TThread)
    private
      fStatusText : string;
      procedure ShowStatus;
    protected
      procedure Execute; override;
    public
      Constructor Create(CreateSuspended : boolean);
    end;

implementation

constructor TRemoteStationSimulator.Create(CreateSuspended : boolean);
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate := True;           // better code...
end;

procedure TRemoteStationSimulator.ShowStatus;
// this method is executed by the mainthread and can therefore access all GUI elements.
begin
  // Form1.Caption := fStatusText;
end;

procedure TRemoteStationSimulator.Execute;
var
  newStatus : string;
begin
  fStatusText := 'TRemotStationSimulator Starting...';
  Synchronize(@Showstatus);
  fStatusText := 'TRemotStationSimulator Running...';
  while (not Terminated) and (true {[any condition required]}) do
    begin
      //...
      //[here goes the code of the main thread loop]
      //...
      if NewStatus <> fStatusText then
        begin
          fStatusText := newStatus;
          Synchronize(@Showstatus);
        end;
    end;
end;

end.

