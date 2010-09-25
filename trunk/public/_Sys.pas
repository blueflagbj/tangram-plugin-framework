{------------------------------------
  功能说明：为方便调用常用接口
  创建日期：2010/04/13
  作者：WZW
  版权：WZW
-------------------------------------}
unit _Sys;
{$weakpackageunit on}
interface

uses SysUtils,Classes,SysSvc,SysInfoIntf,DialogIntf,MainFormIntf,LogIntf,
     DBIntf,EncdDecdIntf;

Type
  ISysSvcHelper=Interface
    ['{B5DAC302-0608-4472-BA4E-53A9A42CA057}']
    function SysInfo:ISysInfo;
    function Dialogs:IDialog;
    function Form:IFormMgr;
    function Log:ILog;
    function EncdDecd:IEncdDecd;
  end;

  TSysSvcHelper=Class(TInterfacedObject,ISysSvcHelper)
  private

  public
    function SysInfo:ISysInfo;
    function Dialogs:IDialog;
    function Form:IFormMgr;
    function Log:ILog;
    function EncdDecd:IEncdDecd;
  end;

  function Sys:ISysSvcHelper;
  
implementation

const ERR_IntfNotFound='找不到%s接口！';

procedure RiaseIntfNotFoundErr(IID:TGUID);
begin
  Raise Exception.CreateFmt(ERR_IntfNotFound,[GUIDToString(IID)]);
end;

function Sys:ISysSvcHelper;
begin
  Result:=TSysSvcHelper.Create;
end;

{ TSysSvcHelper }

function TSysSvcHelper.Dialogs: IDialog;
begin
  if SysService.QueryInterface(IDialog,Result)<>S_OK then
    RiaseIntfNotFoundErr(IDialog);
end;

function TSysSvcHelper.EncdDecd: IEncdDecd;
begin
  if SysService.QueryInterface(IEncdDecd,Result)<>S_OK then
    RiaseIntfNotFoundErr(IEncdDecd);
end;

function TSysSvcHelper.Form: IFormMgr;
begin
  if SysService.QueryInterface(IFormMgr,Result)<>S_OK then
    RiaseIntfNotFoundErr(IFormMgr);
end;

function TSysSvcHelper.Log: ILog;
begin
  if SysService.QueryInterface(ILog,Result)<>S_OK then
    RiaseIntfNotFoundErr(ILog);
end;

function TSysSvcHelper.SysInfo: ISysInfo;
begin
  if SysService.QueryInterface(ISysInfo,Result)<>S_OK then
    RiaseIntfNotFoundErr(ISysInfo);
end;

end. 

