unit Test2FrameDB;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, Buttons;

type
  TFrame3 = class(TFrame)
    SpeedButton2: TSpeedButton;
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
uses _sys,Test2DB;
{$R *.dfm}

procedure TFrame3.SpeedButton2Click(Sender: TObject);
begin
  sys.Form.CreateForm(TFrmTestDB);
end;

end.
