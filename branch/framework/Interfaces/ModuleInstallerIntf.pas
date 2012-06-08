{------------------------------------
  功能说明：模块安装接口
  创建日期：2011/04/19
  作者：wei
  版权：wei
-------------------------------------}
unit ModuleInstallerIntf;
{$weakpackageunit on}
interface

Type
  IModuleInstaller=Interface
    ['{97E777E9-0541-47DD-BCD3-4DB2BCB3145D}']
    procedure InstallModule(const ModuleFile:String);
    procedure UninstallModule(const ModuleFile:string);
  End;
implementation

end.
