{------------------------------------
  功能说明：接口说明服务
  创建日期：2010/06/07
  作者：WZW
  版权：WZW
-------------------------------------}
unit uSvcInfoObj;

interface

uses sysUtils,Classes,SysFactory,SvcInfoIntf;

Type
  TSvcInfoObj=Class(TInterfacedObject,ISvcInfoEx,ISvcInfo)
  private
  protected
  {ISvcInfo}
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;
  {ISvcInfoEx}
    procedure GetSvcInfo(Intf:ISvcInfoGetter);
  Public
  End;

implementation

uses SysFactoryMgr,FactoryIntf;

{procedure Create_SvcInfoObj(out anInstance: IInterface);
begin
  anInstance:=TSvcInfoObj.Create;
end;}

{ TSvcInfoObj }

function TSvcInfoObj.GetComments: String;
begin
  Result:='用于获取当前系统所有接口信息';
end;

function TSvcInfoObj.GetModuleName: String;
begin
  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TSvcInfoObj.GetTitle: String;
begin
  Result:='接口说明服务(ISvcInfoEx)';
end;

function TSvcInfoObj.GetVersion: String;
begin
  Result:='20100607.001';
end;

procedure TSvcInfoObj.GetSvcInfo(Intf: ISvcInfoGetter);
var i:integer;
    aFactory:TFactory;
    SvcInfoEx:ISvcInfoEx;
begin
  if Intf=nil then exit;

  for i:=0 to FactoryManager.FactoryList.Count-1 do
  begin
    aFactory:=FactoryManager.FactoryList.Items[i];
    if aFactory.GetInterface(ISvcInfoEx,SvcInfoEx) then
      SvcInfoEx.GetSvcInfo(Intf);
  end;
end;

initialization
  //TIntfFactory.Create(ISvcInfoEx,@Create_SvcInfoObj);
finalization
end.