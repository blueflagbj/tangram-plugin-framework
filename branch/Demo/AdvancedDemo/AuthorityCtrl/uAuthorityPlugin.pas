{-----------------------------------
  功能说明：权限包导出的菜单
  创建日期：2010/05/15
  作者：wzw
  版权：wzw
-------------------------------------}
unit uAuthorityPlugin;

interface

uses SysUtils,Classes,Graphics,MainFormIntf,MenuRegIntf,
     uTangramModule,SysModule,RegIntf;

Type
  TAuthorityPlugin=Class(TModule)
  private
    procedure RoleMgrClick(Sender:TObject);
    procedure UserMgrClick(Sender:TObject);
  protected
  public
    Constructor Create; override;
    Destructor Destroy; override;

    procedure Init; override;
    procedure final; override;
    procedure Notify(Flags: Integer; Intf: IInterface;Param:Integer); override;

    class procedure RegisterModule(Reg:IRegistry);override;
    class procedure UnRegisterModule(Reg:IRegistry);override;

    Class procedure RegMenu(Reg:IMenuReg);
    Class procedure UnRegMenu(Reg:IMenuReg);
  end;
implementation

uses SysSvc,MenuEventBinderIntf,uUserMgr,uRoleMgr,uConst;

const
  InstallKey='SYSTEM\LOADMODULE\SYS';
  ValueKey='Module=%s;load=True';

  Key_RoleMgr     ='ID_79DF059E-63F3-4C06-829D-888A53B1A471';
  Key_UserMgr     ='ID_D0F119E7-3404-4213-91A7-7790B9CDD7FB';
{ TCustomMenu }

constructor TAuthorityPlugin.Create;
var EventReg:IMenuEventBinder;
begin
  EventReg:=SysService as IMenuEventBinder;
  //绑定事件
  EventReg.RegMenuEvent(Key_RoleMgr,self.RoleMgrClick);
  EventReg.RegMenuEvent(Key_UserMgr,self.UserMgrClick);
end;

destructor TAuthorityPlugin.Destroy;
begin

  inherited;
end;

procedure TAuthorityPlugin.final;
begin
  inherited;

end;

procedure TAuthorityPlugin.Init;
begin
  inherited;

end;

procedure TAuthorityPlugin.Notify(Flags: Integer; Intf: IInterface;Param:Integer);
begin
  if Flags=Flags_RegAuthority then
  begin
    TFrmRoleMgr.RegistryAuthority;
    TfrmUserMgr.RegistryAuthority;
  end;
end;

class procedure TAuthorityPlugin.RegisterModule(Reg: IRegistry);
var ModuleFullName,ModuleName,Value:String;
begin
  //注册菜单
  self.RegMenu(Reg as IMenuReg);
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


class procedure TAuthorityPlugin.RegMenu(Reg: IMenuReg);
begin
  Reg.RegMenu(Key_RoleMgr,     '系统管理\权限\角色管理');
  Reg.RegMenu(Key_UserMgr,     '系统管理\权限\用户管理');
end;

class procedure TAuthorityPlugin.UnRegisterModule(Reg: IRegistry);
var ModuleName:String;
begin
  //取消注册菜单
  self.UnRegMenu(Reg as IMenuReg);
  //取消注册包
  if Reg.OpenKey(InstallKey) then
  begin
    ModuleName:=ExtractFileName(SysUtils.GetModuleName(HInstance));
    if Reg.DeleteValue(ModuleName) then
      Reg.SaveData;
  end;
end;

class procedure TAuthorityPlugin.UnRegMenu(Reg: IMenuReg);
begin
  Reg.UnRegMenu(Key_RoleMgr);
  Reg.UnRegMenu(Key_UserMgr);
end;

procedure TAuthorityPlugin.RoleMgrClick(Sender: TObject);
begin
  (SysService as IFormMgr).CreateForm(TfrmRoleMgr);
end;

procedure TAuthorityPlugin.UserMgrClick(Sender: TObject);
begin
  (SysService as IFormMgr).CreateForm(TfrmUserMgr);
end;

initialization
  RegisterModuleClass(TAuthorityPlugin);
finalization

end.
