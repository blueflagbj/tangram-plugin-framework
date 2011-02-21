unit uModule2Plugin;

interface

uses SysUtils,Classes,uTangramModule,PluginBase,RegIntf;

Type
  TUserPlugin=Class(TPlugin)
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

uses SysSvc,notifyIntf,uFrmWebbrowser,uFrmOptions;

const
  InstallKey='SYSTEM\LOADMODULE\USER';
  ValueKey='Module=%s;load=True';

{ TUserPlugin }

constructor TUserPlugin.Create;
begin 
  inherited;
  //当前模块加载后执行，不要在这里取接口...
end;

destructor TUserPlugin.Destroy;
begin
  //当前模块卸载前执行，不要在这里取接口...
  inherited;
end;

procedure TUserPlugin.Init;
begin
  //初始化，所有模块加载完成后会执行到这里，在这取接口是安全的...
  inherited;
end;

procedure TUserPlugin.final;
begin
  //终始化，卸载模块前会执行到这里，这里取接口是安全的...
  inherited;
end;

procedure TUserPlugin.Notify(Flags: Integer; Intf: IInterface);
begin
  if Flags=NotifyFlag then
  begin
    (Intf as IClsRegister).RegCls('浏览器',TFrmWebbrowser);
    (Intf as IClsRegister).RegCls('选    项',TFrmOptions);
  end;
end;

class procedure TUserPlugin.RegisterModule(Reg: IRegistry);
var ModuleFullName,ModuleName,Value:String;
begin
  //注册模块
  if Reg.OpenKey(InstallKey,True) then 
  begin 
    ModuleFullName:=SysUtils.GetModuleName(HInstance);
    ModuleName:=ExtractFileName(ModuleFullName);
    Value:=Format(ValueKey,[ModuleFullName]); 
    Reg.WriteString(ModuleName,Value); 
    Reg.SaveData; 
  end;
end;

class procedure TUserPlugin.UnRegisterModule(Reg: IRegistry);
var ModuleName:String; 
begin 
  //取消注册模块
  if Reg.OpenKey(InstallKey) then
  begin 
    ModuleName:=ExtractFileName(SysUtils.GetModuleName(HInstance));
    if Reg.DeleteValue(ModuleName) then 
      Reg.SaveData;
  end;
end; 

initialization
  RegisterPluginClass(TUserPlugin);
finalization

end.
