{------------------------------------
  功能说明：
  创建日期：
  作者：
  版权：
-------------------------------------}
unit BaseExport;

interface

uses RegIntf,RegPluginIntf;


procedure InstallPackage(Reg:IRegistry);//安装包
procedure UnInstallPackage(Reg:IRegistry);//卸载包
procedure RegisterPlugIn(Reg:IRegPlugin);//注册插件

exports
  InstallPackage,
  UnInstallPackage,
  RegisterPlugIn;

implementation

uses _sys,DialogIntf;

procedure InstallPackage(Reg:IRegistry);//安装包
begin

end;

procedure UnInstallPackage(Reg:IRegistry);//卸载包
begin

end;

procedure RegisterPlugIn(Reg:IRegPlugin);//注册插件
begin

end;

initialization

finalization

end.

