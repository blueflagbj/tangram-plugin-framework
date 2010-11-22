{------------------------------------
  功能说明：实现IDBAccess接口
  创建日期：2010/04/26
  作者：wzw
  版权：wzw
-------------------------------------}
unit DBAccess;

interface

uses SysUtils,DB,DBClient,Provider,ADODB,DBIntf,SvcInfoIntf;

Type
  TDBOperation=Class(TInterfacedObject,IDBAccess,ISvcInfo)
  private
    FConnection:TADOConnection;
  protected
  {IDBOperation}
    procedure BeginTrans;
    procedure CommitTrans;
    procedure RollbackTrans;

    procedure QuerySQL(Cds:TClientDataSet;Const SQLStr:String);

    procedure ExecuteSQL(Const SQLStr:String);
    procedure ApplyUpdate(Const TableName:String;Cds:TClientDataSet);
  {ISvcInfo}
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;
  public
    Constructor Create;
    Destructor Destroy;override;
  end;

implementation

uses SysSvc,SysFactory,ActiveX;

{ TDBOperation }

function TDBOperation.GetComments: String;
begin
  Result:='用于数据库操作';
end;

function TDBOperation.GetModuleName: String;
begin
  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TDBOperation.GetTitle: String;
begin
  Result:='数据库操作接口(IDBAccess)';
end;

function TDBOperation.GetVersion: String;
begin
  Result:='20100426.001';
end;

procedure TDBOperation.BeginTrans;
begin
  FConnection.BeginTrans;
end;

procedure TDBOperation.CommitTrans;
begin
  FConnection.CommitTrans;
end;

procedure TDBOperation.RollbackTrans;
begin
  FConnection.RollbackTrans;
end;

procedure TDBOperation.ExecuteSQL(const SQLStr: String);
var TmpQry:TADOQuery;
begin
  TmpQry:=TADOQuery.Create(nil);
  try
    TmpQry.Connection:=FConnection;
    TmpQry.SQL.Text:=SQLStr;
    TmpQry.ExecSQL;
  finally
    tmpQry.Free;
  end;
end;

procedure TDBOperation.QuerySQL(Cds: TClientDataSet; const SQLStr: String);
var Provider:TDataSetProvider;
    TmpQry:TADOQuery;
begin
  TmpQry:=TADOQuery.Create(nil);
  Provider:=TDataSetProvider.Create(nil);
  try
    TmpQry.Connection:=FConnection;
    Provider.DataSet:=TmpQry;
    TmpQry.SQL.Text:=SQLStr;
    TmpQry.Open;
    Cds.Data:=Provider.Data;
  finally
    tmpQry.Free;
    Provider.Free;
  end;
end;

procedure TDBOperation.ApplyUpdate(const TableName: String;
  Cds: TClientDataSet);
const SQL='select * from %s where 1<>1';
var Provider:TDataSetProvider;
    TmpQry:TADOQuery;
    SQLStr:String;
    ECount:Integer;
begin
  if Cds.State in [dsEdit, dsInsert] then cds.Post;
  if Cds.ChangeCount=0 then exit;
  TmpQry:=TADOQuery.Create(nil);
  Provider:=TDataSetProvider.Create(nil);
  try
    SQLStr:=Format(SQL,[TableName]);
    Provider.ResolveToDataSet:=False;
    Provider.UpdateMode := upWhereChanged;
    TmpQry.Connection:=FConnection;
    Provider.DataSet:=TmpQry;
    TmpQry.SQL.Text:=SQLStr;
    TmpQry.Open;

    Provider.ApplyUpdates(Cds.Delta,-1,ECount);
    Cds.MergeChangeLog;
  finally
    tmpQry.Free;
    Provider.Free;
  end;
end;

constructor TDBOperation.Create;
var Obj:TObject;
    DBConn:IDBConnection;
begin
  DBConn:=SysService as IDBConnection;
  if not DBConn.Connected then
    DBConn.Connected:=True;
  Obj:=DBConn.GetDBConnection;
  if Obj is TADOConnection then
    FConnection:=TADOConnection(Obj);
end;

destructor TDBOperation.Destroy;
begin

  inherited;
end;

procedure CreateDBOperation(out anInstance: IInterface);
begin
  CoInitialize(nil);
  anInstance:=TDBOperation.Create;
  CoUnInitialize;
end;

initialization
  TIntfFactory.Create(IDBAccess,@CreateDBOperation);
finalization
end.
