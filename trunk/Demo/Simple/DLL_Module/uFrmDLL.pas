unit uFrmDLL;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmDLL = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    edt_Caption: TEdit;
    Button2: TButton;
    ColorBox1: TColorBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDLL: TfrmDLL;

implementation

uses SysSvc,uIntf;

{$R *.dfm}

procedure TfrmDLL.Button1Click(Sender: TObject);
var Intf:IIntf1;
begin
  Intf:=SysService as IIntf1;//获取IIntf1接口,IIntf1是主窗体实现的
  Intf.SetMainFormCaption(self.edt_Caption.Text);
end;

procedure TfrmDLL.Button2Click(Sender: TObject);
var Intf:IIntf1;
begin
  Intf:=SysService as IIntf1;//获取IIntf1接口,IIntf1是主窗体实现的

  Intf.SetMainFormColor(ColorBox1.Selected);
end;

end.
