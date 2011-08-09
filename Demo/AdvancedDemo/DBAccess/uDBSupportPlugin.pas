unit uDBSupportPlugin;

interface
uses SysUtils,Classes,Graphics,MainFormIntf,MenuRegIntf,
     uTangramModule,SysModule,RegIntf;

Type
  TDBSupportPlugin=Class(TModule)
  private
  public
    Constructor Create; override;
    Destructor Destroy; override;

    procedure Init; override;
    procedure final; override;
    procedure Notify(Flags: Integer; Intf: IInterface;Param:Cardinal); override;

    class procedure RegisterModule(Reg:IRegistry);override;
    class procedure UnRegisterModule(Reg:IRegistry);override;
  End;
implementation
const InstallKey='SYSTEM\LOADMODULE\DBSUPPORT';
      ValueKey='Module=%s;load=True';
{ TDBSupportPlugin }

constructor TDBSupportPlugin.Create;
begin
  inherited;

end;

destructor TDBSupportPlugin.Destroy;
begin

  inherited;
end;

procedure TDBSupportPlugin.final;
begin
  inherited;

end;

procedure TDBSupportPlugin.Init;
begin
  inherited;

end;

procedure TDBSupportPlugin.Notify(Flags: Integer; Intf: IInterface;Param:Cardinal);
begin
  inherited;

end;

class procedure TDBSupportPlugin.RegisterModule(Reg: IRegistry);
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

class procedure TDBSupportPlugin.UnRegisterModule(Reg: IRegistry);
var ModuleName:String;
begin
  if Reg.OpenKey(InstallKey) then
  begin
    ModuleName:=ExtractFileName(SysUtils.GetModuleName(HInstance));
    if Reg.DeleteValue(ModuleName) then
      Reg.SaveData;
  end;
end;
initialization
  RegisterModuleClass(TDBSupportPlugin);
finalization
end.
