{------------------------------------
  功能说明：系统服务
  创建日期：2008/11/09
  作者：wzw
  版权：wzw
-------------------------------------}
unit SysSvc;

interface

uses SysUtils,Windows,Classes,FactoryIntf;

Type
  TSysService=Class(TObject,IInterface)
  private
    FRefCount: Integer;
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
   // Constructor Create;
   // Destructor Destroy;override;
  end;

  function SysService:IInterface;

implementation

uses SysFactoryMgr;

var
  FSysService:IInterface;

function SysService:IInterface;
begin
  if not Assigned(FSysService) then
    FSysService:=TSysService.Create;
    
  Result:=FSysService;
end;

{ TSysService }

function TSysService._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TSysService._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

function TSysService.QueryInterface(const IID: TGUID; out Obj): HResult;
var FactoryIntf:ISysFactory;
begin
  Result:=E_NOINTERFACE;
  if self.GetInterface(IID,Obj) then
    Result:=S_OK
  else begin
    FactoryIntf:=FactoryManager.FindFactory(IID);
    if Assigned(FactoryIntf) then
    begin
      FactoryIntf.CreateInstance(IID,Obj);
      Result:=S_OK;
    end;
  end;
end;

initialization
  FSysService:=nil;
finalization
  FSysService:=nil;
end.
