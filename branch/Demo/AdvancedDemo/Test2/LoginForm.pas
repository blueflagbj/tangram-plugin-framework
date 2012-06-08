unit LoginForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,uBaseForm, StdCtrls, Buttons,SysSvc,DBIntf;

type
  Tfrm_Login = class(TBaseForm)
    Label1: TLabel;
    Label2: TLabel;
    cb_User: TComboBox;
    edt_Psw: TEdit;
    btn_Ok: TBitBtn;
    btn_Cancel: TBitBtn;
    Label3: TLabel;
    procedure btn_OkClick(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FListFiller:IListFiller;
  public
    { Public declarations }
  end;

var
  frm_Login: Tfrm_Login;

implementation

uses _Sys,SysInfoIntf;

{$R *.dfm}

procedure Tfrm_Login.btn_OkClick(Sender: TObject);
var idx:Integer;
    DataRecord:IDataRecord;
    LoginUserInfo:PLoginUserInfo;
begin
  idx:=self.cb_User.ItemIndex;
  if idx<>-1 then
  begin
    if FListFiller=nil then exit;
    DataRecord:=FListFiller.GetDataRecord(idx,self.cb_User.Items);
    if DataRecord.FieldValueAsString('Psw')=edt_Psw.Text then
    begin
      LoginUserInfo:=sys.SysInfo.LoginUserInfo;
      LoginUserInfo^.UserID:=DataRecord.FieldValueAsInteger('ID');
      LoginUserInfo^.UserName:=DataRecord.FieldValueAsString('UserName');
      LoginUserInfo^.RoleID:=DataRecord.FieldValueAsInteger('RoleID');
      LoginUserInfo^.IsAdmin:=False;//注意:这样还没查出来...
      self.ModalResult:=mrOK;
    end else Sys.Dialogs.ShowError('密码错误！');
  end else Sys.Dialogs.Warning('请选择一个用户！');
end;

procedure Tfrm_Login.Label3Click(Sender: TObject);
begin
  //inherited;
  (SysService as IDBConnection).ConnConfig;
end;

procedure Tfrm_Login.FormCreate(Sender: TObject);
begin
  inherited;
  FListFiller:=nil;
end;

procedure Tfrm_Login.FormDestroy(Sender: TObject);
begin
  inherited;
  if FListFiller=nil then exit;
  FListFiller.ClearList(self.cb_User.Items);
end;

procedure Tfrm_Login.FormShow(Sender: TObject);
begin
  inherited;
  if SysService.QueryInterface(IListFiller,FListFiller)=S_OK then
    FListFiller.FillList('[User]','UserName',self.cb_User.Items)
  else sys.Dialogs.ShowError('无法取得IListFiller接口！');
end;

end.
