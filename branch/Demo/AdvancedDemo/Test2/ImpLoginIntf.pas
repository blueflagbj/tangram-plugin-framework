{------------------------------------
  功能说明：实现IlogIn接口
  创建日期：2008/12/31
  作者：WZW
  版权：WZW
-------------------------------------}
unit ImpLoginIntf;


interface

uses SysUtils,Controls,LoginIntf,SvcInfoIntf;

Type
  TLogin=Class(TInterfacedObject,ILogin,ISvcInfo)
  private
  protected
    {ILogin}
    function Login:Boolean;
    procedure ChangeUser;
    procedure LockSystem;
    {ISvcInfo}
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;
  public
  End;

implementation

uses SysSvc,LoginForm,SysFactory,MainFormIntf;

{ TLogin }

function TLogin.GetComments: String;
begin
  Result:='登录框接口。进入系统时检查登录用，也用于锁定系统和切换用户。';
end;

function TLogin.GetModuleName: String;
begin
  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TLogin.GetTitle: String;
begin
  Result:='登录框接口(ILogin)';
end;

function TLogin.GetVersion: String;
begin
  Result:='20100421.001';
end;

procedure TLogin.ChangeUser;
begin
 // sys.Dialogs.ShowError('ILogin.ChangeUser方法未实现！');
end;

procedure TLogin.LockSystem;
begin
  //sys.Dialogs.ShowError('ILogin.LockSystem方法未实现！');
end;

function TLogin.Login:Boolean;
begin
  frm_Login:=Tfrm_Login.Create(nil);
  try
    Result:=frm_Login.ShowModal=mrOk;
  finally
    frm_Login.Free;
  end;
end;

function Create_LoginObj(param:Integer):TObject;
begin
  Result:=TLogin.Create;
end;

initialization
  TIntfFactory.Create(ILogin,@Create_LoginObj);
finalization

end.

