{------------------------------------
  功能说明：系统核心包导出单元
  创建日期：2008/11/19
  作者：wzw
  版权：wzw
-------------------------------------}
unit CoreExport;

interface

uses Classes,SysUtils,RegIntf;

procedure Load(Intf:IInterface);//加载包后调用
procedure Init;//加载所有包后调用
procedure Final;//程序退出前调用

procedure InstallPackage(Reg:IRegistry);//安装包
procedure UnInstallPackage(Reg:IRegistry);//卸载包

exports
  Load,
  Init,
  final,

  InstallPackage,
  UnInstallPackage;
  
implementation

uses SysSvc,SysFactoryMgr,SysPluginMgr;

var PluginMgr:TPluginMgr;

procedure Load(Intf:IInterface);
begin
  PluginMgr:=TPluginMgr.Create;
  PluginMgr.LoadPackage(Intf);
end;

procedure Init;
begin
  PluginMgr.Init;
end;

procedure Final;
begin
  PluginMgr.final;
  //释放工厂管理的实例
  FactoryManager.ReleaseInstances;

  PluginMgr.Free;
end;

procedure InstallPackage(Reg:IRegistry);//安装包
begin

end;

procedure UnInstallPackage(Reg:IRegistry);//卸载包
begin

end;

initialization

finalization

end.

