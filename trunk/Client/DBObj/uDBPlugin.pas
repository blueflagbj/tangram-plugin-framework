unit uDBPlugin;

interface
uses SysUtils,Classes,Graphics,MainFormIntf,MenuRegIntf,
     uTangramModule,PluginBase,RegIntf;
Type
  TDBPlugin=Class(TPlugin)
  private
  public
    Constructor Create; override;
    Destructor Destroy; override;

    procedure Init; override;
    procedure final; override;
    procedure Register(Flags: Integer; Intf: IInterface); override;

    class procedure RegisterModule(Reg:IRegistry);override;
    class procedure UnRegisterModule(Reg:IRegistry);override;
  End;
implementation
const
  InstallKey='SYSTEM\LOADPACKAGE\DBSUPPORT';
  ValueKey='Package=%s;load=True';
{ TDBPlugin }

constructor TDBPlugin.Create;
begin
  inherited;

end;

destructor TDBPlugin.Destroy;
begin

  inherited;
end;

procedure TDBPlugin.final;
begin
  inherited;

end;

procedure TDBPlugin.Init;
begin
  inherited;

end;

procedure TDBPlugin.Register(Flags: Integer; Intf: IInterface);
begin
  inherited;

end;

class procedure TDBPlugin.RegisterModule(Reg: IRegistry);
var ModuleFullName,ModuleName,Value:String;
begin
  //注册包
  if Reg.OpenKey(InstallKey,True) then
  begin
    ModuleFullName:=SysUtils.GetModuleName(HInstance);
    ModuleName:=ExtractFileName(ModuleFullName);
    Value:=Format(ValueKey,[ModuleFullName]);
    Reg.WriteString(ModuleName,Value);
    Reg.SaveData;
  end;
end;

class procedure TDBPlugin.UnRegisterModule(Reg: IRegistry);
var ModuleName:String;
begin
  //取消注册包
  if Reg.OpenKey(InstallKey) then
  begin
    ModuleName:=ExtractFileName(SysUtils.GetModuleName(HInstance));
    if Reg.DeleteValue(ModuleName) then
      Reg.SaveData;
  end;
end;

initialization
  RegisterPluginClass(TDBPlugin);
finalization
end.
