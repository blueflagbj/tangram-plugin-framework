{------------------------------------
  功能说明：实现ILog接口
  创建日期：2008/11/21
  作者：wzw
  版权：wzw
-------------------------------------}
unit uLog;

interface

uses SysUtils,DateUtils,LogIntf,SvcInfoIntf;

Type
  TLogObj=Class(TInterfacedObject,ILog,ISvcInfo)
  private
    procedure WriteToFile(const Msg:string);
  protected
    {ILog}
    procedure WriteLog(const Str:String);
    procedure WriteLogFmt(const Str:String;const Args: array of const);
    function GetLogFileName:String;
    {ISvcInfo}
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;
  public
    Constructor Create;
    Destructor Destroy;override;
  End;
  
implementation

uses SysSvc,SysFactory;

{ TLogObj }

function TLogObj.GetLogFileName: String;
var Logpath:String;
begin
  Logpath:=ExtractFilePath(ParamStr(0))+'Logs\';
  if not DirectoryExists(Logpath) then
    ForceDirectories(Logpath);

  Result:=Logpath+FormatDateTime('YYYY-MM-DD',Now)+'.log';
end;

constructor TLogObj.Create;
begin

end;

destructor TLogObj.Destroy;
begin

  inherited;
end;

function TLogObj.GetComments: String;
begin
  Result:='封装日志相关操作';
end;

function TLogObj.GetModuleName: String;
begin
  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TLogObj.GetTitle: String;
begin
  Result:='日志接口(ILog)';
end;

function TLogObj.GetVersion: String;
begin
  Result:='20110417.002';
end;

procedure TLogObj.WriteLog(const Str: String);
begin
  WriteToFile(Str);
end;

procedure TLogObj.WriteLogFmt(const Str: String; const Args: array of const);
begin
  WriteToFile(Format(Str,Args));
end;

procedure TLogObj.WriteToFile(const Msg: string);
var FileName:String;
    FileHandle:TextFile;
begin
  FileName:=GetLogFileName;
  assignfile(FileHandle,FileName);
  try
    if FileExists(FileName) then
      append(FileHandle)//Reset(FileHandle)
    else ReWrite(FileHandle);

    WriteLn(FileHandle,FormatDateTime('[HH:MM:SS]',now)+'  '+Msg);
  finally
    CloseFile(FileHandle);
  end;
end;

function Create_LogObj(param:Integer):TObject;
begin
  Result:=TLogObj.Create;
end;

initialization
  TIntfFactory.Create(ILog,@Create_LogObj);
finalization

end.
