{------------------------------------
  功能说明：系统信息接口
  创建日期：2008/11/12
  作者：wzw
  版权：wzw
-------------------------------------}
unit SysInfoIntf;
{$weakpackageunit on}
interface
Type
  PLoginUserInfo=^TLoginUserInfo;
  TLoginUserInfo=Record
    UserID:Integer;
    UserName:String;
    RoleID:Integer;
    IsAdmin:Boolean;
  end;
  
  ISysInfo=Interface
    ['{E06C3E07-6865-405C-9EC6-6384BB4CB5DD}']
    function RegistryFile:string;//注册表文件
    function AppPath:string;//程序目录
    function ErrPath:string;//错误日志目录

    function LoginUserInfo:PLoginUserInfo;
  End;
implementation

end.
