{------------------------------------
  功能说明：工厂管理
  创建日期：2010/04/20
  作者：WZW
  版权：WZW
-------------------------------------}
unit SysFactoryMgr;

interface

uses SysUtils,Classes,Windows,FactoryIntf,SvcInfoIntf,uHashList,uIntfObj;

Type
  TSysFactoryList = class(TObject)
  private
    FLock: TRTLCriticalSection;
    FList:TList;
    function LockList: TList;
    procedure UnlockList;

    function GetItems(Index: integer): TFactory;
    function GetCount: Integer;
  protected

  public
    Constructor Create;
    Destructor Destroy;override;

    function Add(aFactory: TFactory): integer;
    function IndexOfIID(const IID:TGUID):Integer;
    function GetFactory(const IID: TGUID): TFactory;
    function FindFactory(const IID:TGUID): TFactory;
    function Remove(aFactory:TFactory):Integer;
    property Items[Index: integer]: TFactory read GetItems; default;
    property Count:Integer Read GetCount;
  end;

  TSysFactoryManager=Class(TIntfObj,IEnumKey)
  private
    FSysFactoryList:TSysFactoryList;
    FIndexList:ThashList;
    FKeyList:TStrings;
  protected
    {IEnumKey}
    procedure EnumKey(const IIDStr:String);
  public
    procedure RegisterFactory(aIntfFactory:TFactory);
    procedure UnRegisterFactory(aFactory:TFactory); overload;
    procedure UnRegisterFactory(IID:TGUID); overload;
    function FindFactory(const IID:TGUID): TFactory;
    property FactoryList:TSysFactoryList Read FSysFactoryList;
    function Exists(const IID:TGUID):Boolean;
    procedure ReleaseInstances;

    Constructor Create;
    Destructor Destroy;override;
  end;

  //注册接口异常类
  ERegistryIntfException=Class(Exception);

function FactoryManager:TSysFactoryManager;

implementation

uses SysMsg;

var FFactoryManager:TSysFactoryManager;

function FactoryManager:TSysFactoryManager;
begin
  if FFactoryManager=nil then
    FFactoryManager:=TSysFactoryManager.Create;

  Result:=FFactoryManager;
end;

{ TSysFactoryList }

function TSysFactoryList.Add(aFactory: TFactory): integer;
begin
  self.LockList;
  try
    Result := FList.Add(Pointer(aFactory));
  finally
    self.UnlockList;
  end;
end;

constructor TSysFactoryList.Create;
begin
  Inherited;
  InitializeCriticalSection(FLock);
  FList:=TList.Create;
end;

destructor TSysFactoryList.Destroy;
var i:Integer;
begin
  //LockList;
  try
    for i :=Flist.Count - 1 downto 0  do
      TObject(FList[i]).Free;

    FList.Free;
    inherited Destroy;
  finally
   // UnlockList;
    DeleteCriticalSection(FLock);
  end;
end;

function TSysFactoryList.FindFactory(const IID: TGUID): TFactory;
var
  idx:integer;
begin
  result := nil;
  idx:=self.IndexOfIID(IID);
  if idx<>-1 then
    Result:=TFactory(FList[idx]);
end;

function TSysFactoryList.GetCount: Integer;
begin
  Result:=FList.Count;
end;

function TSysFactoryList.GetFactory(const IID: TGUID): TFactory;
begin
  Result := FindFactory(IID);
  if not Assigned(result) then
    Raise Exception.CreateFmt(Err_IntfNotFound,[GUIDToString(IID)]);
end;

function TSysFactoryList.GetItems(Index: integer): TFactory;
begin
  Result := TFactory(FList[Index]);
end;

function TSysFactoryList.IndexOfIID(const IID: TGUID): Integer;
var
  i:integer;
begin
  result := -1;
  for i := 0 to (FList.Count - 1) do
  begin
    if TFactory(FList[i]).Supports(IID) then
    begin
      result := i;
      Break;
    end;
  end;
end;

function TSysFactoryList.LockList: TList;
begin
  EnterCriticalSection(FLock);
  Result := FList;
end;

procedure TSysFactoryList.UnlockList;
begin
  LeaveCriticalSection(FLock);
end;

function TSysFactoryList.Remove(aFactory: TFactory):Integer;
begin
  self.LockList;
  try
    Result:=FList.Remove(Pointer(aFactory));
  finally
    self.UnlockList;
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

function TSysFactoryManager.FindFactory(const IID: TGUID): TFactory;
var IIDStr:String;
    PFactory:Pointer;
begin
  Result:=nil;
  IIDStr:=GUIDToString(IID);
  PFactory:=FIndexList.ValueOf(IIDStr);
  if PFactory<>nil then
    Result:=TFactory(PFactory)
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

procedure TSysFactoryManager.RegisterFactory(aIntfFactory: TFactory);
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
  for I := 0 to self.FSysFactoryList.Count-1 do
    self.FSysFactoryList.Items[i].ReleaseInstance;
end;

procedure TSysFactoryManager.EnumKey(const IIDStr: String);
begin
  self.FIndexList.Remove(IIDStr);
end;

procedure TSysFactoryManager.UnRegisterFactory(aFactory: TFactory);
begin
  if Assigned(aFactory) then
  begin
    aFactory.EnumKeys(self);
    aFactory.ReleaseInstance;
    FSysFactoryList.Remove(aFactory);
  end;
end;

procedure TSysFactoryManager.UnRegisterFactory(IID: TGUID);
begin
  self.UnRegisterFactory(FSysFactoryList.GetFactory(IID));
end;

initialization
  FFactoryManager:=nil;
finalization
  FFactoryManager.Free;
end.
