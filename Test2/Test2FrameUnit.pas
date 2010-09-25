unit Test2FrameUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, Buttons;

type
  TFrame2 = class(TFrame)
    SpeedButton1: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
uses _sys,Test2Form2;
{$R *.dfm}

procedure TFrame2.SpeedButton1Click(Sender: TObject);
begin
  Sys.Form.CreateForm(TForm3);
end;

end.
