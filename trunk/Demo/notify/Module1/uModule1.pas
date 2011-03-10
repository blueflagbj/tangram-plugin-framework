unit uModule1;

interface

uses SysUtils,Classes,uTangramModule,SysModule,RegIntf;

Type
  TUserModule=Class(TModule)
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

uses SysSvc,notifyIntf,uFrmSendEmail;

const
  InstallKey='SYSTEM\LOADMODULE\USER';
  ValueKey='Module=%s;load=True';

{ TUserModule }

constructor TUserModule.Create;
begin 
  inherited;
  //当前模块加载后执行，不要在这里取接口...
end;

destructor TUserModule.Destroy;
begin
  //当前模块卸载前执行，不要在这里取接口...
  inherited;
end;

procedure TUserModule.Init;
begin
  //初始化，所有模块加载完成后会执行到这里，在这取接口是安全的...
  inherited;
end;

procedure TUserModule.final;
begin
  //终始化，卸载模块前会执行到这里，这里取接口是安全的...
  inherited;
end;

procedure TUserModule.Notify(Flags: Integer; Intf: IInterface);
begin
  if Flags=NotifyFlag then
  begin
    (Intf as IClsRegister).RegCls('发邮件',TfrmSendEmail);
  end;
end;

class procedure TUserModule.RegisterModule(Reg: IRegistry);
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

class procedure TUserModule.UnRegisterModule(Reg: IRegistry);
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
  RegisterModuleClass(TUserModule);
finalization

end.
