{------------------------------------
  功能说明：平台注册表操作接口
  创建日期：2008/11/11
  作者：wzw
  版权：wzw
-------------------------------------}
unit RegIntf;
{$weakpackageunit on}
interface

uses Classes;

Type
  IRegistry=Interface
    ['{80140700-9F09-4FB1-B9B3-D4B987DDC04A}']
    function OpenKey(const Key:Widestring;CanCreate:Boolean=False):boolean;
    function DeleteKey(const Key:Widestring):boolean;
    function KeyExists(const Key:Widestring):boolean;
    procedure GetKeyNames(Strings: TStrings);
    procedure GetValueNames(Strings: TStrings);
    function DeleteValue(const Name:Widestring):boolean;
    function ValueExists(const ValueName:Widestring):boolean;

    //function ReadCurrency(const Name: Widestring):Currency;
    //function ReadBinaryData(const Name: Widestring; var Buffer; BufSize: Integer): Integer;
    function ReadBool(const aName: Widestring;out Value: Boolean):boolean;
    function ReadDate(const aName: Widestring;out Value: TDateTime):boolean;
    function ReadDateTime(const aName: Widestring; out Value: TDateTime):boolean;
    function ReadFloat(const aName: Widestring; out Value: Double):boolean;
    function ReadInteger(const aName: Widestring; out Value: Integer):boolean;
    function ReadString(const aName:Widestring; out Value: Widestring):boolean;
    function ReadTime(const aName: Widestring; out Value: TDateTime):boolean;

    //procedure WriteCurrency(const Name: Widestring; Value: Currency);
    //procedure WriteBinaryData(const Name: Widestring; var Buffer; BufSize: Integer);
    procedure WriteBool(const aName: Widestring; Value: Boolean);
    procedure WriteDate(const aName: Widestring; Value: TDateTime);
    procedure WriteDateTime(const aName: Widestring; Value: TDateTime);
    procedure WriteFloat(const aName: Widestring; Value: Double);
    procedure WriteInteger(const aName: Widestring; Value: Integer);
    procedure WriteString(const aName, Value: Widestring);
    procedure WriteTime(const aName: Widestring; Value: TDateTime);

    procedure SaveData;
  End;

  ILoadRegistryFile=Interface
    ['{73C5771C-8FFC-42D5-8A0C-A2D77F4C58A1}']
    procedure LoadRegistryFile(const FileName:Widestring);
  End;
implementation

end.
