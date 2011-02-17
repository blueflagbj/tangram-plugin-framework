unit Test2DB;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, DB, DBClient, StdCtrls, Buttons, ExtCtrls,
  DBCtrls,uBaseForm,AuthoritySvrIntf;

type
  TFrmTestDB = class(TBaseForm)
    cds: TClientDataSet;
    ds: TDataSource;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    Button1: TButton;
    DBNavigator1: TDBNavigator;
    BitBtn1: TBitBtn;
    Button2: TButton;
    ComboBox1: TComboBox;
    Button5: TButton;
    Button3: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboBox1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
  protected
    Class procedure RegAuthority(aIntf:IAuthorityRegistrar);override;
    procedure HandleAuthority(const Key:String;aEnable:Boolean);override;
  public
    { Public declarations }
  end;

var
  FrmTestDB: TFrmTestDB;

implementation

uses SysSvc,DBIntf,_Sys,MainFormIntf;

{$R *.dfm}
const
  Key_Query='{1A451528-814F-4F90-AA0B-8ECA3728321E}';//查询权限
  Key_Post='{81110FB4-0C78-4CD9-87DF-282E3ED481E7}';//提交权限
  
procedure TFrmTestDB.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TFrmTestDB.BitBtn1Click(Sender: TObject);
var DBAC:IDBAccess;
    SqlStr:String;
    c:Integer;
begin
  c:=GetTickCount;
  DBAC:=SysService as IDBAccess;
  SqlStr:='select * from [test]';
  DBAC.QuerySQL(Cds,SqlStr);
  BitBtn1.Caption:=Format('查询(用时%d毫秒)',[GetTickCount-c]);
end;

procedure TFrmTestDB.Button1Click(Sender: TObject);
var DBAC:IDBAccess;
begin
  DBAC:=SysService as IDBAccess;
  DBAC.BeginTrans;
  try
    DBAC.ApplyUpdate('[test]',cds);
    DBAC.CommitTrans;
    //sys.Dialogs.ShowMessage('保存成功！');
  Except
    on E:Exception do
    begin
      DBAC.RollbackTrans;
      Sys.Dialogs.ShowError(E);
    end;
  end;
end;

procedure TFrmTestDB.Button2Click(Sender: TObject);
begin
  (SysService as IDBConnection).ConnConfig;
end;

procedure TFrmTestDB.HandleAuthority(const Key: String; aEnable: Boolean);
begin
  if Key=Key_Query then
    BitBtn1.Enabled:=aEnable
  else if Key=Key_Post then
    Button1.Enabled:=aEnable;
end;

class procedure TFrmTestDB.RegAuthority(aIntf: IAuthorityRegistrar);
begin
  aIntf.RegAuthorityItem(Key_Query,'测试权限\数据库操作','查询',True);
  aIntf.RegAuthorityItem(Key_Post,'测试权限\数据库操作','提交',True);
end;

procedure TFrmTestDB.Button5Click(Sender: TObject);
var Intf:IListFiller;
begin
  Intf:=SysService as IListFiller;
  Intf.ClearList(ComboBox1.Items);
  Intf.FillList('[test]','aName',ComboBox1.Items);
end;

procedure TFrmTestDB.FormDestroy(Sender: TObject);
begin
  inherited;
  (SysService as IListFiller).ClearList(self.ComboBox1.Items);//记得要释放
end;

procedure TFrmTestDB.ComboBox1Click(Sender: TObject);
var a,b:string;
    idx:Integer;
    DataRecord:IDataRecord;
begin
  idx:=self.ComboBox1.ItemIndex;
  if idx<>-1 then
  begin
    DataRecord:=(SysService as IListFiller).GetDataRecord(idx,self.ComboBox1.Items);
    a:=DataRecord.FieldValueAsString('ID');
    b:=DataRecord.FieldValueAsString('aName');
    Sys.Dialogs.ShowMessageFmt('ID=%s aName=%s',[a,b]);
  end;
end;

procedure TFrmTestDB.Button3Click(Sender: TObject);
begin
  (SysService as IFormMgr).CloseForm(self);
end;

end.
