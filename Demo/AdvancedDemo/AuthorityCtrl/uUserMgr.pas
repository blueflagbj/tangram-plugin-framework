unit uUserMgr;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseForm,AuthoritySvrIntf, Grids, DBGrids, ComCtrls, ToolWin,
  ImgList, DB, DBClient,DBIntf,SysSvc,_Sys;

type
  TfrmUserMgr = class(TBaseForm)
    imgList: TImageList;
    ToolBar1: TToolBar;
    btn_New: TToolButton;
    Btn_Edit: TToolButton;
    btn_Delete: TToolButton;
    ToolButton7: TToolButton;
    btn_Save: TToolButton;
    Grid_User: TDBGrid;
    cds: TClientDataSet;
    ds: TDataSource;
    btn_Refresh: TToolButton;
    ToolButton2: TToolButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn_NewClick(Sender: TObject);
    procedure Btn_EditClick(Sender: TObject);
    procedure btn_RefreshClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn_SaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Grid_UserDblClick(Sender: TObject);
    procedure btn_DeleteClick(Sender: TObject);
  private
    DBAC:IDBAccess;
    procedure LoadData;
    procedure SaveData;
  protected
    Class procedure RegAuthority(aIntf:IAuthorityRegistrar);override;
    procedure HandleAuthority(const Key:String;aEnable:Boolean);override;
  public
    { Public declarations }
  end;

var
  frmUserMgr: TfrmUserMgr;

implementation

uses uEdtUser;

{$R *.dfm}
Const Key1='{0DA9CD26-BAC5-4417-B989-8D39581289B8}';

procedure TfrmUserMgr.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if cds.ChangeCount>0 then
  begin
    if sys.Dialogs.Ask('用户管理','数据已改变，是否保存？') then
      self.SaveData;
  end;
  Action:=caFree;
end;

class procedure TfrmUserMgr.RegAuthority(aIntf: IAuthorityRegistrar);
begin
  aIntf.RegAuthorityItem(Key1,'系统管理\权限','用户管理',True);
end;

procedure TfrmUserMgr.HandleAuthority(const Key: String; aEnable: Boolean);
begin
  if Key=Key1 then
  begin
    if not aEnable then Raise Exception.Create('对不起，你没有权限！');
  end;
end;

procedure TfrmUserMgr.btn_NewClick(Sender: TObject);
begin
  inherited;
  frmEdtUser:=TfrmEdtUser.Create(nil);
  try
    frmEdtUser.Caption:='新增用户';
    if frmEdtUser.ShowModal=mrOK then
    begin
      cds.Append;
      cds.FieldByName('UserName').AsString:=frmEdtUser.UserName;
      cds.FieldByName('Psw').AsString     :=frmEdtUser.Psw;
      cds.FieldByName('RoleID').AsInteger :=frmEdtUser.RoleID;
      cds.FieldByName('RoleName').AsString:=frmEdtUser.RoleName;
      cds.Post;
    end;
  finally
    frmEdtUser.Free;
  end;
end;

procedure TfrmUserMgr.Btn_EditClick(Sender: TObject);
begin
  inherited;
  if cds.IsEmpty then exit;
  frmEdtUser:=TfrmEdtUser.Create(nil);
  try
    frmEdtUser.Caption:='编辑用户';
    frmEdtUser.UserName:=cds.FieldByName('UserName').AsString;
    frmEdtUser.Psw     :=cds.FieldByName('Psw').AsString;
    frmEdtUser.RoleID  :=cds.FieldByName('RoleID').AsInteger;
    if frmEdtUser.ShowModal=mrOK then
    begin
      cds.Edit;
      cds.FieldByName('UserName').AsString:=frmEdtUser.UserName;
      cds.FieldByName('Psw').AsString     :=frmEdtUser.Psw;
      cds.FieldByName('RoleID').AsInteger :=frmEdtUser.RoleID;
      cds.FieldByName('RoleName').AsString:=frmEdtUser.RoleName;
      cds.Post;
    end;
  finally
    frmEdtUser.Free;
  end;
end;

procedure TfrmUserMgr.LoadData;
const sql='select * from [User]';
begin
  DBAC.QuerySQL(cds,sql);
end;

procedure TfrmUserMgr.btn_RefreshClick(Sender: TObject);
begin
  inherited;
  self.LoadData;
end;

procedure TfrmUserMgr.FormCreate(Sender: TObject);
begin
  inherited;
  DBAC:=SysService as IDBAccess;
end;

procedure TfrmUserMgr.SaveData;
begin
  if cds.ChangeCount=0 then exit;
  DBAC.BeginTrans;
  try
    DBAC.ApplyUpdate('[User]',cds);
    DBAC.CommitTrans;
  Except
    on E:Exception do
    begin
      DBAC.RollbackTrans;
      sys.Dialogs.ShowError(E);
    end;
  end;
end;                           

procedure TfrmUserMgr.btn_SaveClick(Sender: TObject);
begin
  inherited;
  self.SaveData;
end;

procedure TfrmUserMgr.FormShow(Sender: TObject);
begin
  inherited;
  self.LoadData;
end;

procedure TfrmUserMgr.Grid_UserDblClick(Sender: TObject);
begin
  inherited;
  Btn_Edit.Click;
end;

procedure TfrmUserMgr.btn_DeleteClick(Sender: TObject);
begin
  inherited;
  if cds.IsEmpty then exit;
  if sys.Dialogs.Confirm('用户管理','是否要删除当前用户？') then
    cds.Delete;
end;

end.
