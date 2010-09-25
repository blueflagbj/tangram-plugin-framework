unit uFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, Buttons;

type
  TFrame4 = class(TFrame)
    SpeedButton1: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses SysSvc,InvokeServerIntf,_sys;

{$R *.dfm}

procedure TFrame4.SpeedButton1Click(Sender: TObject);
var Intf:IInvokeServer;
    d:TDateTime;
begin
  Intf:=SysService as IInvokeServer;
  d:=Intf.AppServer.GetDateTime;
  Sys.Dialogs.ShowMessageFmt('服务器时间：%s',[DateTimeToStr(d)]);
end;

end.
