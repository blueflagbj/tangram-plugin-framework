unit uEncdDecdPlugin;

interface

uses SysUtils,uTangramModule,SysModule,RegIntf;

Type
  TEncdDecdPlugin=Class(TModule)
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

const
  InstallKey='SYSTEM\LOADMODULE\UTILS';//这里要改成相应的KEY
{ TEncdDecdPlugin }

constructor TEncdDecdPlugin.Create;
begin
  inherited;

end;

destructor TEncdDecdPlugin.Destroy;
begin

  inherited;
end;

procedure TEncdDecdPlugin.final;
begin
  inherited;

end;

procedure TEncdDecdPlugin.Init;
begin
  inherited;

end;

procedure TEncdDecdPlugin.Notify(Flags: Integer; Intf: IInterface;Param:Cardinal);
begin
  inherited;

end;

class procedure TEncdDecdPlugin.RegisterModule(Reg: IRegistry);
begin
  //注册包
  DefaultRegisterModule(Reg,InstallKey);
end;

class procedure TEncdDecdPlugin.UnRegisterModule(Reg: IRegistry);
begin
  //取消注册包
  DefaultUnRegisterModule(Reg,InstallKey);
end;

initialization
  RegisterModuleClass(TEncdDecdPlugin);
finalization
end.
