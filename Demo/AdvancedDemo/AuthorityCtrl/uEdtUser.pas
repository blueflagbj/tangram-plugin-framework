unit uEdtUser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseForm, StdCtrls, Buttons,SysSvc,DBIntf,_Sys;

type
  TfrmEdtUser = class(TBaseForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btn_OK: TBitBtn;
    btn_Cancel: TBitBtn;
    edt_UserName: TEdit;
    edt_Psw: TEdit;
    cb_Role: TComboBox;
    procedure btn_OKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FListFiller:IListFiller;
    function GetPsw: String;
    function GetRoleID: Integer;
    function GetUserName: String;
    procedure SetPsw(const Value: String);
    procedure SetRoleID(const Value: Integer);
    procedure SetUserName(const Value: String);
    function GetRoleName: string;
    { Private declarations }
  public
    property UserName:String Read GetUserName Write SetUserName;
    property Psw:String Read GetPsw Write SetPsw;
    property RoleID:Integer Read GetRoleID Write SetRoleID;
    property RoleName:string Read GetRoleName;
  end;

var
  frmEdtUser: TfrmEdtUser;

implementation

{$R *.dfm}

procedure TfrmEdtUser.btn_OKClick(Sender: TObject);
begin
  inherited;
  if edt_UserName.Text='' then
  begin
    sys.Dialogs.Warning('用户名不能为空！');
    edt_UserName.SetFocus;
    exit;
  end;
  if cb_Role.ItemIndex=-1 then
  begin
    sys.Dialogs.Warning('请选择角色！');
    cb_Role.SetFocus;
    exit;
  end;
  self.ModalResult:=mrOK;
end;

procedure TfrmEdtUser.FormCreate(Sender: TObject);
begin
  inherited;
  FListFiller:=SysService as IListFiller;
  FListFiller.FillList('[Role]','RoleName',self.cb_Role.Items);
end;

procedure TfrmEdtUser.FormDestroy(Sender: TObject);
begin
  inherited;
  FListFiller.ClearList(self.cb_Role.Items);
end;

function TfrmEdtUser.GetPsw: String;
begin
  Result:=self.edt_Psw.Text;
end;

function TfrmEdtUser.GetRoleID: Integer;
var idx:Integer;
    DataRecord:IDataRecord;
begin
  Result:=0;
  idx:=self.cb_Role.ItemIndex;
  if idx<>-1 then
  begin
    DataRecord:=FListFiller.GetDataRecord(idx,self.cb_Role.Items);
    Result:=DataRecord.FieldValueAsInteger('ID');
  end;
end;

function TfrmEdtUser.GetRoleName: string;
begin
  Result:=self.cb_Role.Text;
end;

function TfrmEdtUser.GetUserName: String;
begin
  Result:=self.edt_UserName.Text;
end;

procedure TfrmEdtUser.SetPsw(const Value: String);
begin
  self.edt_Psw.Text:=Value;
end;

procedure TfrmEdtUser.SetRoleID(const Value: Integer);
var i:Integer;
    DataRecord:IDataRecord;
begin
  for i:=0 to self.cb_Role.Items.Count-1 do
  begin
    DataRecord:=FListFiller.GetDataRecord(i,self.cb_Role.Items);
    if DataRecord.FieldValueAsInteger('ID')=Value then
    begin
      self.cb_Role.ItemIndex:=i;
      exit;
    end;
  end;
end;

procedure TfrmEdtUser.SetUserName(const Value: String);
begin
  self.edt_UserName.Text:=Value;
end;

end.
