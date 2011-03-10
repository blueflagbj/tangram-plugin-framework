{------------------------------------
  功能说明：模块导出单元
  创建日期：2011.01.04
  作者：wei
  版权：wei
-------------------------------------}
unit uTangramModule;
{$weakpackageunit on}
interface

uses SysUtils,RegIntf,SysModule;

procedure InstallModule(Reg:IRegistry);
procedure UnInstallModule(Reg:IRegistry);

function GetModuleClass:TModuleClass;
/////////////////////////////////////////////////////////////
procedure RegisterModuleClass(ModuleClass:TModuleClass);
procedure DefaultRegisterModule(Reg:IRegistry;const InstallKey:string;load:Boolean=True);
procedure DefaultUnRegisterModule(Reg:IRegistry;const InstallKey:String);

Exports
  InstallModule,
  UnInstallModule,
  GetModuleClass;


implementation

var FModuleClass:TModuleClass;

procedure RegisterModuleClass(ModuleClass:TModuleClass);
begin
  //这里也许要处理重复注册。。。
  FModuleClass:=ModuleClass;
end;

procedure DefaultRegisterModule(Reg:IRegistry;const InstallKey:string;load:Boolean);
const ValueKey='Module=%s;load=%s';
var ModuleFullName,ModuleName,Value:String;
begin
  if Reg=nil then exit;
  if Reg.OpenKey(InstallKey,True) then
  begin
    ModuleFullName:=SysUtils.GetModuleName(HInstance);
    ModuleName:=ExtractFileName(ModuleFullName);
    Value:=Format(ValueKey,[ModuleFullName,BoolToStr(load,True)]);
    Reg.WriteString(ModuleName,Value);
    Reg.SaveData;
  end;
end;

procedure DefaultUnRegisterModule(Reg:IRegistry;const InstallKey:String);
var ModuleName:String; 
begin
  if Reg=nil then exit;
  if Reg.OpenKey(InstallKey) then
  begin
    ModuleName:=ExtractFileName(SysUtils.GetModuleName(HInstance));
    if Reg.DeleteValue(ModuleName) then
      Reg.SaveData;
  end;
end;
///////////////////////////////////////////////////////

procedure InstallModule(Reg:IRegistry);
begin
  if FModuleClass<>nil then
    FModuleClass.RegisterModule(Reg);
end;

procedure UnInstallModule(Reg:IRegistry);
begin
  if FModuleClass<>nil then
    FModuleClass.UnRegisterModule(Reg);
end;

function GetModuleClass:TModuleClass;
begin
  Result:=FModuleClass;
end;

//initialization
//  FModuleClass:=nil;
//finalization

end.
