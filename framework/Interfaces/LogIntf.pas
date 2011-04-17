{------------------------------------
  功能说明：系统日志接口
  创建日期：2008/11/20
  作者：wzw
  版权：wzw
-------------------------------------}
unit LogIntf;
{$weakpackageunit on}
interface

uses SysUtils;

Type
  ILog=Interface
    ['{472FD4AD-F589-4D4D-9051-A20D37B7E236}']
    procedure WriteLog(const Str:String);
    procedure WriteLogFmt(const Str:String;const Args: array of const);
    function GetLogFileName:String;
  End;
  
implementation

end.
