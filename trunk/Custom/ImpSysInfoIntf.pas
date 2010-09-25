{------------------------------------
  功能说明：实现系统信息
  创建日期：2008/11/12
  作者：wzw
  版权：wzw
-------------------------------------}
unit ImpSysInfoIntf;

interface

uses sysUtils,SysInfoIntf,uConst,SysFactory,SvcInfoIntf;

Type
  TSysInfoObj=Class(TInterfacedObject,ISysInfo,ISvcInfo)
  private
    FLoginUserInfo:TLoginUserInfo;
  protected
    {ISysInfo}
    function RegistryFile:string;//注册表文件
    function AppPath:string;//程序目录
    function ErrPath:string;//错误日志目录
    {ISvcInfo}
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;

    function LoginUserInfo:PLoginUserInfo;
  public
  End;

implementation

uses IniFiles;

{ TSysInfoIntfObj }

function TSysInfoObj.AppPath: string;
begin
  Result:=ExtractFilePath(Paramstr(0));
end;

function TSysInfoObj.ErrPath: string;
begin
  Result:=AppPath+'error';
  if not DirectoryExists(Result) then
    ForceDirectories(Result);
end;

function TSysInfoObj.GetComments: String;
begin
  Result:='通过它可以取得系统一些信息，比如错误日志保存目录，注册表文件名以及当前登录用户等。';
end;

function TSysInfoObj.GetModuleName: String;
begin
  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TSysInfoObj.GetTitle: String;
begin
  Result:='系统信息接口(ISysInfo)';
end;

function TSysInfoObj.GetVersion: String;
begin
  Result:='20100421.001';
end;

function TSysInfoObj.LoginUserInfo: PLoginUserInfo;
begin
  Result:=@FLoginUserInfo;
end;

function TSysInfoObj.RegistryFile: string;
var IniFile:string;
    ini:TIniFile;
begin
  IniFile:=self.AppPath+'Root.ini';
  ini:=TiniFile.Create(IniFile);
  try
    Result:=self.AppPath+ini.ReadString('Default','Reg','');
  finally
    ini.Free;
  end;
end;

procedure CreateSysInfoObj(out anInstance: IInterface);
begin
  anInstance:=TSysInfoObj.Create;
end;

initialization
  TSingletonFactory.Create(ISysInfo,@CreateSysInfoObj);
finalization
end.
