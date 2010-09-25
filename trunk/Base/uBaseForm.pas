{------------------------------------
  功能说明：所有窗体的主先类
  修改日期：2009/05/11
  作者：wzw
  版权：wzw
-------------------------------------}
unit uBaseForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,_sys, StdCtrls,AuthoritySvrIntf;

type
  TBaseForm = class(TForm,IAuthorityCtrl)
  private
    procedure Intf_RegAuthority(aIntf:IAuthorityRegistrar);
    procedure DoHandleAuthority;
  protected
    Class procedure RegAuthority(aIntf:IAuthorityRegistrar);Virtual;
    {IAuthorityCtrl}
    procedure IAuthorityCtrl.RegAuthority=Intf_RegAuthority;
    procedure HandleAuthority(const Key:String;aEnable:Boolean);Virtual;
  public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
    Class procedure RegistryAuthority;//注册权限
  end;

  TRegAuthorityPro=procedure(aIntf:IAuthorityRegistrar) of Object;
  TAuthorityReg=Class(TInterfacedObject,IAuthorityCtrl)
  private
    FRegAuthorityPro: TRegAuthorityPro;
  protected
    {IAuthorityCtrl}
    procedure RegAuthority(aIntf:IAuthorityRegistrar);
    procedure HandleAuthority(const Key:String;aEnable:Boolean);
  public
    Constructor Create(RegAuthorityPro:TRegAuthorityPro);
  end;
var
  BaseForm: TBaseForm;

implementation

uses SysSvc;

{$R *.dfm}

{ TBaseForm }

Constructor TBaseForm.Create(AOwner: TComponent);
begin
  inherited;
  DoHandleAuthority;
end;

Destructor TBaseForm.Destroy;
begin

  inherited;
end;

procedure TBaseForm.DoHandleAuthority;
var AuthoritySvr:IAuthoritySvr;
begin
  if SysService.QueryInterface(IAuthoritySvr,AuthoritySvr)=S_OK then
    AuthoritySvr.AuthorityCtrl(self);
end;

procedure TBaseForm.HandleAuthority(const Key: String; aEnable: Boolean);
begin

end;

procedure TBaseForm.Intf_RegAuthority(aIntf: IAuthorityRegistrar);
begin
  self.RegAuthority(aIntf);
end;

class procedure TBaseForm.RegAuthority(aIntf: IAuthorityRegistrar);
begin

end;

Class procedure TBaseForm.RegistryAuthority;
var AuthoritySvr:IAuthoritySvr;
begin
  if SysService.QueryInterface(IAuthoritySvr,AuthoritySvr)=S_OK then
    AuthoritySvr.RegAuthority(TAuthorityReg.Create(self.RegAuthority));
end;

{ TAuthorityReg }

constructor TAuthorityReg.Create(RegAuthorityPro: TRegAuthorityPro);
begin
  FRegAuthorityPro:=RegAuthorityPro;
end;

procedure TAuthorityReg.HandleAuthority(const Key: String;
  aEnable: Boolean);
begin

end;

procedure TAuthorityReg.RegAuthority(aIntf: IAuthorityRegistrar);
begin
  if Assigned(FRegAuthorityPro) then
    FRegAuthorityPro(aIntf);
end;

end.
