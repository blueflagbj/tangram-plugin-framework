{------------------------------------
  功能说明：工厂管理
  创建日期：2010/04/20
  作者：WZW
  版权：WZW
-------------------------------------}
unit SysFactoryMgr;

interface

uses SysUtils,Classes,FactoryIntf,SvcInfoIntf;

Type
  TSysFactoryList = class(TInterfaceList)
  private
    function GetItems(Index: integer): ISysFactory;
  protected

  public
    function Add(aFactory: ISysFactory): integer;
    function IndexOfIID(const IID:TGUID):Integer;
    function GetFactory(const IID: TGUID): ISysFactory;
    function FindFactory(const IID:TGUID): ISysFactory;
    property Items[Index: integer]: ISysFactory read GetItems; default;
  end;

  TSysFactoryManager=Class(TObject)
  private
    FSysFactoryList:TSysFactoryList;
  protected
  public
    procedure RegistryFactory(aIntfFactory:ISysFactory);
    procedure UnRegistryFactory(aIntfFactory:ISysFactory); overload;
    procedure UnRegistryFactory(IID:TGUID); overload;
    procedure ReleaseInstances;
    function FindFactory(const IID:TGUID): ISysFactory;
    property FactoryList:TSysFactoryList Read FSysFactoryList;
    function Exists(const IID:TGUID):Boolean;

    Constructor Create;
    Destructor Destroy;override;
  end;

  //注册接口异常类
  ERegistryIntfException=Class(Exception);

function FactoryManager:TSysFactoryManager;

implementation

var FFactoryManager:TSysFactoryManager;

function FactoryManager:TSysFactoryManager;
begin
  if FFactoryManager=nil then
    FFactoryManager:=TSysFactoryManager.Create;

  Result:=FFactoryManager;
end;

{ TSysFactoryList }

function TSysFactoryList.Add(aFactory: ISysFactory): integer;
begin
  Result := inherited Add(aFactory);
end;

function TSysFactoryList.FindFactory(const IID: TGUID): ISysFactory;
var
  idx:integer;
begin
  result := nil;
  idx:=self.IndexOfIID(IID);
  if idx<>-1 then
    Result:=Items[idx];
end;

function TSysFactoryList.GetFactory(const IID: TGUID): ISysFactory;
begin
  Result := FindFactory(IID);
  if not Assigned(result) then
    Raise Exception.CreateFmt('未找到%s接口！',[GUIDToString(IID)]);
end;

function TSysFactoryList.GetItems(Index: integer): ISysFactory;
begin
  Result := inherited Items[Index] as ISysFactory
end;

function TSysFactoryList.IndexOfIID(const IID: TGUID): Integer;
var
  i:integer;
begin
  result := -1;
  for i := 0 to (Count - 1) do
  begin
    if Items[i].Supports(IID) then
    begin
      result := i;
      Break;
    end;
  end;
end;

{ TSysFactoryManager }

constructor TSysFactoryManager.Create;
begin
  FSysFactoryList:=TSysFactoryList.Create;
end;

destructor TSysFactoryManager.Destroy;
begin
  FSysFactoryList.Free;
  inherited;
end;

function TSysFactoryManager.Exists(const IID: TGUID): Boolean;
begin
  Result:=FSysFactoryList.IndexOfIID(IID)<>-1;
end;

function TSysFactoryManager.FindFactory(const IID: TGUID): ISysFactory;
begin
  Result:=FSysFactoryList.FindFactory(IID);
end;

procedure TSysFactoryManager.RegistryFactory(aIntfFactory: ISysFactory);
begin
  FSysFactoryList.Add(aIntfFactory);
end;

procedure TSysFactoryManager.ReleaseInstances;
var i:Integer;
begin
  for i:=0 to FSysFactoryList.Count-1 do
    FSysFactoryList.Items[i].ReleaseInstance;
end;

procedure TSysFactoryManager.UnRegistryFactory(aIntfFactory: ISysFactory);
begin
  if Assigned(aIntfFactory) then
  begin
    aIntfFactory.ReleaseInstance;
    FSysFactoryList.Remove(aIntfFactory);
  end;
end;

procedure TSysFactoryManager.UnRegistryFactory(IID: TGUID);
begin
  self.UnRegistryFactory(FSysFactoryList.GetFactory(IID));
end;

initialization
  FFactoryManager:=nil;
finalization
  FreeAndNil(FFactoryManager);
end.
