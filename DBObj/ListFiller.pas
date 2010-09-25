{------------------------------------
  功能说明：实现IListFiller接口
  创建日期：2010/05/17
  作者：wzw
  版权：wzw
-------------------------------------}
unit ListFiller;

interface

uses sysUtils,Classes,DB,DBClient,SysFactory,DBIntf,SvcInfoIntf;

Type
  TListFiller=Class(TInterfacedObject,IListFiller,ISvcInfo)
  private
  protected
  {ISvcInfo}
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;
  {IListFiller}
    procedure FillList(DataSet:TDataSet;const FieldName:String;aList:TStrings);OverLoad;
    procedure FillList(const TableName,FieldName:string;aList:TStrings);Overload;
    procedure ClearList(aList:TStrings);
    procedure DeleteListItem(const Index:Integer;aList:TStrings);

    function GetDataRecord(const Index:Integer;aList:TStrings):IDataRecord;
  Public
  End;

implementation

uses SysSvc;

procedure Create_ListFiller(out anInstance: IInterface);
begin
  anInstance:=TListFiller.Create;
end;

{ TListFiller }

function TListFiller.GetComments: String;
begin
  Result:='用于把某个字段填充到TStringList中';
end;

function TListFiller.GetModuleName: String;
begin
  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TListFiller.GetTitle: String;
begin
  Result:='列表填充接口(IListFiller)';
end;

function TListFiller.GetVersion: String;
begin
  Result:='20100520.002';
end;

procedure TListFiller.FillList(DataSet: TDataSet;Const FieldName: String;
  aList: TStrings);
var DataRecord:IDataRecord;
    FieldValue:String;
begin
  if DataSet=nil then exit;
  if FieldName='' then exit;
  if aList=nil then exit;
  DataSet.DisableControls;
  aList.BeginUpdate;
  try
    DataSet.First;
    while not DataSet.Eof do
    begin
      FieldValue:=DataSet.fieldbyname(FieldName).AsString;
      DataRecord:=SysService as IDataRecord;
      DataRecord.LoadFromDataSet(DataSet);
      DataRecord._AddRef;
      aList.AddObject(FieldValue,TObject(Pointer(DataRecord)));
      DataSet.Next;
    end;
  finally
    DataSet.EnableControls;
    aList.EndUpdate;
  end;
end;

function TListFiller.GetDataRecord(const Index: Integer;
  aList: TStrings): IDataRecord;
begin
  Result:=IDataRecord(Pointer(aList.Objects[Index]));
end;

procedure TListFiller.ClearList(aList: TStrings);
var i:Integer;
begin
  for i:=0 to aList.Count-1 do
    IDataRecord(Pointer(aList.Objects[i]))._Release;
  aList.Clear;
end;

procedure TListFiller.DeleteListItem(const Index: Integer;
  aList: TStrings);
begin
  IDataRecord(Pointer(aList.Objects[Index]))._Release;
  aList.Delete(Index);
end;

procedure TListFiller.FillList(const TableName, FieldName: string;
  aList: TStrings);
const Sql='Select * from %s';
var cds:TClientDataSet;
begin
  cds:=TClientDataSet.Create(nil);
  try
    (SysService as IDBAccess).QuerySQL(Cds,Format(Sql,[TableName]));
    self.FillList(Cds,FieldName,aList);
  finally
    cds.Free;
  end;
end;

initialization
  TIntfFactory.Create(IListFiller,@Create_ListFiller);
finalization
end.