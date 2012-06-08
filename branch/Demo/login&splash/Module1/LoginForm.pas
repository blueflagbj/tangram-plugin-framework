unit LoginForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons,SysSvc;

type
  Tfrm_Login = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    edt_Psw: TEdit;
    btn_Ok: TBitBtn;
    btn_Cancel: TBitBtn;
    edt_UserName: TEdit;
    procedure btn_OkClick(Sender: TObject);
  private

  public
    { Public declarations }
  end;

var
  frm_Login: Tfrm_Login;

implementation

{$R *.dfm}

procedure Tfrm_Login.btn_OkClick(Sender: TObject);
begin
  if (self.edt_UserName.Text='test') and//这里判断用户和密码...
     (self.edt_Psw.Text='123')  then
  begin
    self.ModalResult:=mrOK
  end else showmessage('请输入用户名：test 密码： 123');
end;

end.
