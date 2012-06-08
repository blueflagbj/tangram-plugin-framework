{------------------------------------
  功能说明：数据库操作接口
  创建日期：2010/04/26
  作者：wzw
  版权：wzw
-------------------------------------}
unit DBIntf;
{$weakpackageunit on}
interface

uses Classes,DB,DBClient;

Type
  IDBConnection=Interface
    ['{C2AF5DCA-985A-4915-B2CB-4F3FDD321BA5}']
    function GetConnected:Boolean;
    procedure SetConnected(Const Value:Boolean);
    property Connected:Boolean Read GetConnected Write SetConnected;
    procedure ConnConfig;
    function GetDBConnection:TObject;
  End;

  IDBAccess=Interface
  ['{FC3B34E7-55E3-492E-B029-31646DC7522C}']
    procedure BeginTrans;
    procedure CommitTrans;
    procedure RollbackTrans;

    procedure QuerySQL(Cds:TClientDataSet;Const SQLStr:String);

    procedure ExecuteSQL(Const SQLStr:String);
    procedure ApplyUpdate(Const TableName:String;Cds:TClientDataSet);

    //function ExecProcedure(const ProName:String;Param:Array of Variant):Boolean;
  end;

  IDataRecord=Interface
  ['{7738C1DF-DE2D-46A6-BA4C-AF1F69DBE856}']
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
  end;

  IListFiller=Interface
  ['{ED67EA0E-3385-4EBA-8094-44E26B81077F}']
    procedure FillList(DataSet:TDataSet;const FieldName:String;aList:TStrings);OverLoad;
    procedure FillList(const TableName,FieldName:string;aList:TStrings);Overload;
    procedure ClearList(aList:TStrings);
    procedure DeleteListItem(const Index:Integer;aList:TStrings);

    function GetDataRecord(const Index:Integer;aList:TStrings):IDataRecord;
  end;

implementation

end.
