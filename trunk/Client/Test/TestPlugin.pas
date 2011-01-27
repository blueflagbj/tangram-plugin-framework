unit TestPlugin;

interface

uses SysUtils,Classes,Graphics,MainFormIntf,MenuRegIntf,
     uTangramModule,PluginBase,RegIntf;

Type
  TTestPlugin=Class(TPlugin)
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

const InstallKey='SYSTEM\LOADMODULE\USER';
      ValueKey='Module=%s;load=True';
{ TTestPlugin }

constructor TTestPlugin.Create;
begin
  inherited;

end;

destructor TTestPlugin.Destroy;
begin

  inherited;
end;

procedure TTestPlugin.final;
begin
  inherited;

end;

procedure TTestPlugin.Init;
begin
  inherited;

end;

procedure TTestPlugin.Register(Flags: Integer; Intf: IInterface);
begin
  inherited;

end;

class procedure TTestPlugin.RegisterModule(Reg: IRegistry);
var ModuleFullName,ModuleName,Value:String;
begin
  if Reg.OpenKey(InstallKey,True) then
  begin
    //s:=inttostr(HInstance);
    //MessageBox(GetActiveWindow,pchar(s),'ok',0);
    //exit;
    ModuleFullName:=SysUtils.GetModuleName(HInstance);
    ModuleName:=ExtractFileName(ModuleFullName);
    Value:=Format(ValueKey,[ModuleFullName]);
    Reg.WriteString(ModuleName,Value);
    Reg.SaveData;
  end;
end;

class procedure TTestPlugin.UnRegisterModule(Reg: IRegistry);
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
  RegisterPluginClass(TTestPlugin);
finalization

end.
