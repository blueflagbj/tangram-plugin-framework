{------------------------------------
  功能说明：实现IDataRecord接口
  创建日期：2010/05/17
  作者：wzw
  版权：wzw
-------------------------------------}
unit DataRecord;

interface

uses sysUtils,Classes,Variants,SysFactory,DBIntf,SvcInfoIntf,DB;

Type
  TDataItem=Class(TObject)
  public
    Modified:Variant;
    Data:Variant;
  end;
  TDataRecord=Class(TInterfacedObject,IDataRecord,ISvcInfo)
  private
    FList:TStrings;
    procedure ClearList;
    function FindFieldData(const FieldName:String):TDataItem;
    function GetFieldData(const FieldName:String):TDataItem;
  protected
  {ISvcInfo}
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;
  {IDataRecord}
    procedure LoadFromDataSet(DataSet:TDataSet);
    procedure SaveToDataSet(const KeyFields:String;DataSet:TDataSet;FieldsMapping:string='');
    procedure CloneFrom(DataRecord:IDataRecord);

    function GetFieldValue(const FieldName:String):Variant;
    procedure SetFieldValue(const FieldName:String;Value:Variant);
    property FieldValues[const FieldName: string]: Variant Read GetFieldValue Write SetFieldValue;

    function FieldValueAsString(const FieldName:String):String;
    function FieldValueAsBoolean(const FieldName:String):Boolean;
    function FieldValueAsCurrency(const FieldName:String):Currency;
    function FieldValueAsDateTime(const FieldName:String):TDateTime;
    function FieldValueAsFloat(const FieldName:String):Double;
    function FieldValueAsInteger(const FieldName:String):Integer;

    Function GetFieldCount:Integer;
    Function GetFieldName(Const Index:Integer):String;
  Public
    Constructor Create;
    Destructor Destroy;override;
  End;

implementation

procedure Create_DataRecord(out anInstance: IInterface);
begin
  anInstance:=TDataRecord.Create;
end;

{ TDataRecord }

function TDataRecord.GetModuleName: String;
begin
  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TDataRecord.GetVersion: String;
begin
  Result:='20100517.001';
end;

function TDataRecord.GetComments: String;
begin
  Result:='可以把数据集当做一个记录的集合，可以用本接口读出一条记录，并可以写回数据集。';
end;

function TDataRecord.GetTitle: String;
begin
  Result:='数据记录接口(IDataRecord)';
end;

procedure TDataRecord.ClearList;
var i:Integer;
begin
  for i:=0 to FList.Count-1 do
    FList.Objects[i].Free;
  FList.Clear;
end;

constructor TDataRecord.Create;
begin
  FList:=TStringList.Create;
end;

destructor TDataRecord.Destroy;
begin
  ClearList;
  
  FList.Free;
  inherited;
end;

function TDataRecord.FieldValueAsBoolean(const FieldName: String): Boolean;
var tmpValue:Variant;
begin
  tmpValue:=self.GetFieldValue(FieldName);
  if VarIsNull(tmpValue) then
    Result:=False
  else Result:=tmpValue;
end;

function TDataRecord.FieldValueAsCurrency(
  const FieldName: String): Currency;
var tmpValue:Variant;
begin
  tmpValue:=self.GetFieldValue(FieldName);
  if VarIsNull(tmpValue) then
    Result:=0
  else Result:=tmpValue;
end;

function TDataRecord.FieldValueAsDateTime(
  const FieldName: String): TDateTime;
var tmpValue:Variant;
begin
  tmpValue:=self.GetFieldValue(FieldName);
  if VarIsNull(tmpValue) then
    Result:=0
  else Result:=tmpValue;
end;

function TDataRecord.FieldValueAsFloat(const FieldName: String): Double;
var tmpValue:Variant;
begin
  tmpValue:=self.GetFieldValue(FieldName);
  if VarIsNull(tmpValue) then
    Result:=0.0
  else Result:=tmpValue;
end;

function TDataRecord.FieldValueAsInteger(const FieldName: String): Integer;
var tmpValue:Variant;
begin
  tmpValue:=self.GetFieldValue(FieldName);
  if VarIsNull(tmpValue) then
    Result:=0
  else Result:=tmpValue;
end;

function TDataRecord.FieldValueAsString(const FieldName: String): String;
begin
  Result:=VarToStr(GetFieldValue(FieldName));
end;

function TDataRecord.GetFieldCount: Integer;
begin
  Result:=FList.Count;
end;

function TDataRecord.GetFieldName(const Index: Integer): String;
begin
  Result:=FList[Index];
end;

function TDataRecord.GetFieldValue(const FieldName: String): Variant;
var DataItem:TDataItem;
begin
  DataItem:=self.GetFieldData(FieldName);
  Result:=DataItem.Data;
end;

procedure TDataRecord.LoadFromDataSet(DataSet: TDataSet);
var DataItem:TDataItem;
    i:Integer;
begin
  self.ClearList;
  if DataSet=nil then exit;
  for i:=0 to DataSet.FieldCount-1 do
  begin
    DataItem:=TDataItem.Create;
    DataItem.Modified:=False;
    DataItem.Data:=DataSet.Fields[i].Value;
    FList.AddObject(DataSet.Fields[i].FieldName,DataItem);
  end;
end;

procedure TDataRecord.SaveToDataSet(const KeyFields:String;DataSet:TDataSet;FieldsMapping:string);
var i,idx:Integer;
    DataItem:TDataItem;

    FieldValues:Variant;
    FieldList,FieldMappingList:TStrings;
    s:string;
begin
  FieldList:=TStringList.Create;
  FieldMappingList:=TStringList.Create;
  try
    FieldList.Delimiter:=';';
    FieldList.DelimitedText:=KeyFields;

    FieldMappingList.Delimiter:=';';
    FieldMappingList.DelimitedText:=FieldsMapping;
    
    FieldValues:=VarArrayCreate([0,FieldList.Count-1],varVariant);
    for i:=0 to FieldList.Count-1 do
    begin
      s:=FieldMappingList.Values[FieldList[i]];
      if s='' then
        s:=FieldList[i];

      idx:=FList.IndexOf(s);
      if idx<>-1 then
      begin
        DataItem:=TDataItem(FList.Objects[idx]);
        FieldValues[i]:=DataItem.Data;
      end else FieldValues[i]:=NULL;
    end;
    if DataSet.Locate(KeyFields,FieldValues,[]) then
      DataSet.Edit
    else DataSet.Append;

    for i:=0 to DataSet.FieldCount-1 do
    begin
      s:=FieldMappingList.Values[DataSet.Fields[i].FieldName];
      if s='' then s:=DataSet.Fields[i].FieldName;
      idx:=FList.IndexOf(s);
      if idx<>-1 then
      begin
        DataItem:=TDataItem(FList.Objects[idx]);
        if DataItem.Modified then
          DataSet.Fields[i].Value:=DataItem.Data;
      end;
    end;

    DataSet.Post;
  finally
    FieldList.Free;
    FieldMappingList.Free;
  end;
end;

procedure TDataRecord.SetFieldValue(const FieldName: String;
  Value: Variant);
var DataItem:TDataItem;
begin
  DataItem:=self.FindFieldData(FieldName);
  if DataItem<>nil then
  begin
    DataItem.Modified:=True;
    DataItem.Data:=Value;
  end else begin
    DataItem:=TDataItem.Create;
    DataItem.Modified:=True;
    DataItem.Data:=Value;
    FList.AddObject(FieldName,DataItem);
  end;
end;

function TDataRecord.GetFieldData(const FieldName: String): TDataItem;
begin
  Result:=FindFieldData(FieldName);
  if Result=nil then Raise Exception.CreateFmt('字段[%s]不存在！',[FieldName]);
end;

function TDataRecord.FindFieldData(const FieldName: String): TDataItem;
var idx:Integer;
begin
  Result:=nil;
  idx:=FList.IndexOf(FieldName);
  if Idx<>-1 then
    Result:=TDataItem(FList.Objects[idx]);
end;

procedure TDataRecord.CloneFrom(DataRecord: IDataRecord);
var i:Integer;
    FieldName:string;
begin
  if DataRecord=nil then exit;
  self.ClearList;
  for i:=0 to DataRecord.GetFieldCount-1 do
  begin
    FieldName:=DataRecord.GetFieldName(i);
    self.FieldValues[FieldName]:=DataRecord.FieldValues[FieldName];
  end;
end;

initialization
  TIntfFactory.Create(IDataRecord,@Create_DataRecord);
finalization

end.