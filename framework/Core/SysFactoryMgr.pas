{------------------------------------
  功能说明：工厂管理
  创建日期：2010/04/20
  作者：WZW
  版权：WZW
-------------------------------------}
unit SysFactoryMgr;

interface

uses SysUtils,Classes,FactoryIntf,SvcInfoIntf,uHashList;

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

  TSysFactoryManager=Class(TObject,IInterface,IEnumKey)
  private
    FSysFactoryList:TSysFactoryList;
    FIndexList:ThashList;
    FKeyList:TStrings;
  protected
    {IInterface}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    {IEnumKey}
    procedure EnumKey(const IIDStr:String);
  public
    procedure RegisterFactory(aIntfFactory:ISysFactory);
    procedure UnRegisterFactory(aIntfFactory:ISysFactory); overload;
    procedure UnRegisterFactory(IID:TGUID); overload;
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
  FIndexList:=THashList.Create(256);
  FKeyList  :=TStringList.Create;
end;

destructor TSysFactoryManager.Destroy;
begin
  FSysFactoryList.Free;
  FIndexList.Free;
  FKeyList.Free;
  inherited;
end;

function TSysFactoryManager.Exists(const IID: TGUID): Boolean;
begin
  Result:=FSysFactoryList.IndexOfIID(IID)<>-1;
end;

function TSysFactoryManager.FindFactory(const IID: TGUID): ISysFactory;
var IIDStr:String;
    PFactory:Pointer;
begin
  IIDStr:=GUIDToString(IID);
  PFactory:=FIndexList.ValueOf(IIDStr);
  if PFactory<>nil then
    Result:=ISysFactory(PFactory)
  else begin
    if FKeyList.IndexOf(IIDStr)=-1 then
    begin
      Result:=FSysFactoryList.FindFactory(IID);
      if Result=nil then
        FKeyList.Add(IIDStr)
      else
        FIndexList.Add(IIDStr,Pointer(Result));
    end;
  end;
end;

procedure TSysFactoryManager.RegisterFactory(aIntfFactory: ISysFactory);
var i:Integer;
    IIDStr:String;
    IID:TGUID;
begin
  FSysFactoryList.Add(aIntfFactory);

  for i := FKeyList.Count - 1 downto 0 do
  begin
    IIDStr:=FKeyList[i];
    IID   :=StringToGUID(IIDStr);
    if aIntfFactory.Supports(IID) then
    begin
      FIndexList.Add(IIDStr,Pointer(aIntfFactory));
      FKeyList.Delete(i);
    end;
  end;
end;

procedure TSysFactoryManager.ReleaseInstances;
var i:Integer;
begin
  for i:=0 to FSysFactoryList.Count-1 do
    FSysFactoryList.Items[i].ReleaseInstance;
end;

procedure TSysFactoryManager.EnumKey(const IIDStr: String);
begin
  self.FIndexList.Remove(IIDStr);
end;

procedure TSysFactoryManager.UnRegisterFactory(aIntfFactory: ISysFactory);
begin
  if Assigned(aIntfFactory) then
  begin
    aIntfFactory.EnumKeys(self);
    aIntfFactory.ReleaseInstance;
    FSysFactoryList.Remove(aIntfFactory);
  end;
end;

procedure TSysFactoryManager.UnRegisterFactory(IID: TGUID);
begin
  self.UnRegisterFactory(FSysFactoryList.GetFactory(IID));
end;

function TSysFactoryManager.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TSysFactoryManager._AddRef: Integer;
begin
  Result:=-1;
end;

function TSysFactoryManager._Release: Integer;
begin
  Result:=-1;
end;

initialization
  FFactoryManager:=nil;
finalization
  FreeAndNil(FFactoryManager);
end.
