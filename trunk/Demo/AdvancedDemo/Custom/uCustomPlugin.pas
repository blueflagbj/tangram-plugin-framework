unit uCustomPlugin;

interface
uses SysUtils,Classes,Graphics,MainFormIntf,MenuRegIntf,
     uTangramModule,PluginBase,RegIntf;
Type
  TCustomPlugin=Class(TPlugin)
  private
  public
    Constructor Create; override;
    Destructor Destroy; override;

    procedure Init; override;
    procedure final; override;
    procedure Notify(Flags: Integer; Intf: IInterface); override;

    class procedure RegisterModule(Reg:IRegistry);override;
    class procedure UnRegisterModule(Reg:IRegistry);override;
  End;
implementation

const InstallKey='SYSTEM\LOADMODULE';
      ValueKey='Module=%s;load=True';//($APP_PATH)\
{ TCustomPlugin }

constructor TCustomPlugin.Create;
begin
  inherited;

end;

destructor TCustomPlugin.Destroy;
begin

  inherited;
end;

procedure TCustomPlugin.final;
begin
  inherited;

end;

procedure TCustomPlugin.Init;
begin
  inherited;

end;

procedure TCustomPlugin.Notify(Flags: Integer; Intf: IInterface);
begin
  inherited;

end;

class procedure TCustomPlugin.RegisterModule(Reg: IRegistry);
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

class procedure TCustomPlugin.UnRegisterModule(Reg: IRegistry);
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
  RegisterPluginClass(TCustomPlugin);
finalization
end.
