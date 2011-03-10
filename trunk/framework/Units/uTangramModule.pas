{------------------------------------
  功能说明：模块导出单元
  创建日期：2011.01.04
  作者：wei
  版权：wei
-------------------------------------}
unit uTangramModule;
{$weakpackageunit on}
interface

uses RegIntf,SysModule;

procedure InstallModule(Reg:IRegistry);
procedure UnInstallModule(Reg:IRegistry);

function GetModuleClass:TModuleClass;
/////////////////////
procedure RegisterModuleClass(ModuleClass:TModuleClass);

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
