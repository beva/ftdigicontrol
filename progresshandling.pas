unit ProgressHandling;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LCLType, ExtCtrls;

type
  TMyDrawingControl = class(TCustomControl)
  public
    constructor Create(MyShape: TShape); overload;
    destructor Destroy; override;
    procedure EraseBackground(DC: HDC); override;
    procedure Paint; override;
  private
    LocalShape : TShape;
    Bitmap : TBitmap;
    x_size : integer;
    y_size : integer;
  end;

implementation

constructor TMyDrawingControl.Create(MyShape: TShape);
begin
  inherited Create(nil);
  Bitmap := TBitmap.Create;
  // My stuff
  LocalShape := MyShape;
  Bitmap.Height := MyShape.Height;
  Bitmap.Width  := MyShape.Width;
  x_size := LocalShape.Width;  // Er antagelig unødvendig
  y_size := LocalShape.Height; // Er antagelig unødvendig
end;

destructor TMyDrawingControl.Destroy;
begin
  Bitmap.Free;
  inherited Free;
end;

procedure TMyDrawingControl.EraseBackground(DC: HDC);
begin
  //
end;

procedure TMyDrawingControl.Paint;
begin
  // Test

  Bitmap.Canvas.Pen.Color := clBlue;
  Bitmap.Canvas.Rectangle(2, 2, x_size-4, y_size-4); // Should fill with white
//  Bitmap.Canvas.Rectangle(5, 5, 20, 10); // Should fill with white
  LocalShape.Canvas.Draw(0,0,Bitmap);
end;

end.

