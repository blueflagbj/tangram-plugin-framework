{-----------------------------------
  功能说明：权限包导出的菜单
  创建日期：2010/05/15
  作者：wzw
  版权：wzw
-------------------------------------}
unit uAuthorityPlugin;

interface

uses SysUtils,Windows,PluginBase,MenuRegIntf;

Type
  TAuthorityPlugin=Class(TPlugin)
  private
    procedure RoleMgrClick(Sender:TObject);
    procedure UserMgrClick(Sender:TObject);
  protected
  public
    Constructor Create(Intf: IInterface); override;
    Destructor Destroy; override;

    procedure Init; override;
    procedure final; override;
    procedure Register(Flags: Integer; Intf: IInterface); override;
    
    Class procedure RegMenu(Reg:IMenuReg);
    Class procedure UnRegMenu(Reg:IMenuReg);
  end;
implementation

uses SysSvc,MenuEventBinderIntf,MainFormIntf,uUserMgr,uRoleMgr,uConst;

const
  Key_RoleMgr     ='ID_79DF059E-63F3-4C06-829D-888A53B1A471';
  Key_UserMgr     ='ID_D0F119E7-3404-4213-91A7-7790B9CDD7FB';
{ TCustomMenu }

constructor TAuthorityPlugin.Create(Intf: IInterface);
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

procedure TAuthorityPlugin.Register(Flags: Integer; Intf: IInterface);
begin
  if Flags=Flags_RegAuthority then
  begin
    TFrmRoleMgr.RegistryAuthority;
    TfrmUserMgr.RegistryAuthority;
  end;
end;

class procedure TAuthorityPlugin.RegMenu(Reg: IMenuReg);
begin
  Reg.RegMenu(Key_RoleMgr,     '系统管理\权限\角色管理');
  Reg.RegMenu(Key_UserMgr,     '系统管理\权限\用户管理');
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

end.
