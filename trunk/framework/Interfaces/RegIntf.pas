{ ------------------------------------
  功能说明：平台注册表操作接口
  创建日期：2008/11/11
  作者：wzw
  版权：wzw
  ------------------------------------- }
unit RegIntf;
{$WEAKPACKAGEUNIT on}

interface

uses Classes;

Type
  IRegistry = Interface
    ['{80140700-9F09-4FB1-B9B3-D4B987DDC04A}']
    function OpenKey(const Key: Widestring;
      CanCreate: Boolean = False): Boolean;
    function DeleteKey(const Key: Widestring): Boolean;
    function KeyExists(const Key: Widestring): Boolean;
    procedure GetKeyNames(Strings: TStrings);
    procedure GetValueNames(Strings: TStrings);
    function DeleteValue(const Name: Widestring): Boolean;
    function ValueExists(const ValueName: Widestring): Boolean;

    // function ReadCurrency(const Name: Widestring):Currency;
    // function ReadBinaryData(const Name: Widestring; var Buffer; BufSize: Integer): Integer;
    function ReadBool(const aName: Widestring; out Value: Boolean): Boolean;
    function ReadDateTime(const aName: Widestring;
      out Value: TDateTime): Boolean;
    function ReadFloat(const aName: Widestring; out Value: Double): Boolean;
    function ReadInteger(const aName: Widestring; out Value: Integer): Boolean;
    function ReadString(const aName: Widestring;
      out Value: Widestring): Boolean;

    function ReadBoolDef(const aName: Widestring; Default: Boolean): Boolean;
    function ReadDateTimeDef(const aName: Widestring;
      Default: TDateTime): TDateTime;
    function ReadFloatDef(const aName: Widestring; Default: Double): Double;
    function ReadIntegerDef(const aName: Widestring; Default: Integer): Integer;
    function ReadStringDef(const aName: Widestring;
      Default: Widestring): Widestring;
    // procedure WriteCurrency(const Name: Widestring; Value: Currency);
    // procedure WriteBinaryData(const Name: Widestring; var Buffer; BufSize: Integer);
    procedure WriteBool(const aName: Widestring; Value: Boolean);
    procedure WriteDateTime(const aName: Widestring; Value: TDateTime);
    procedure WriteFloat(const aName: Widestring; Value: Double);
    procedure WriteInteger(const aName: Widestring; Value: Integer);
    procedure WriteString(const aName, Value: Widestring);

    procedure SaveData;
  End;

  ILoadRegistryFile = Interface
    ['{73C5771C-8FFC-42D5-8A0C-A2D77F4C58A1}']
    procedure LoadRegistryFile(const FileName: Widestring);
  End;

implementation

end.
