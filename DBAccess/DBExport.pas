unit DBExport;
interface

uses SysUtils,RegIntf,RegPluginIntf;

procedure InstallPackage(Reg:IRegistry);//安装包
procedure UnInstallPackage(Reg:IRegistry);//卸载包
procedure RegisterPlugIn(Reg:IRegPlugin);//注册插件

exports
  InstallPackage,
  UnInstallPackage,
  RegisterPlugIn;

implementation

const InstallKey='SYSTEM\LOADPACKAGE\DBSUPPORT';
      ValueKey='Package=%s;load=True';

procedure InstallPackage(Reg:IRegistry);
var ModuleFullName,ModuleName,Value:String;
begin
  if Reg.OpenKey(InstallKey,True) then
  begin
    ModuleFullName:=SysUtils.GetModuleName(HInstance);
    ModuleName:=ExtractFileName(ModuleFullName);
    Value:=Format(ValueKey,[ModuleFullName]);
    Reg.WriteString(ModuleName,Value);
    Reg.SaveData;
  end;
end;

procedure UnInstallPackage(Reg:IRegistry);
var ModuleName:String;
begin
  if Reg.OpenKey(InstallKey) then
  begin
    ModuleName:=ExtractFileName(SysUtils.GetModuleName(HInstance));
    if Reg.DeleteValue(ModuleName) then
      Reg.SaveData;
  end;
end;

procedure RegisterPlugIn(Reg:IRegPlugin);//注册插件
begin

end;

initialization

finalization

end.

