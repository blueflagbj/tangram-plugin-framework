{ ------------------------------------
  功能说明：工厂
  创建日期：2010/03/29
  作者：WZW
  版权：WZW
  ------------------------------------- }
unit SysFactory;

interface

Uses Classes, SysUtils, FactoryIntf, SvcInfoIntf;

Type
  // 工厂基类
  TBaseFactory = Class(TFactory, ISvcInfoEx)
  private
  protected
    FIntfGUID: TGUID;
    { ISvcInfoEx }
    procedure GetSvcInfo(Intf: ISvcInfoGetter); virtual; abstract;
  public
    Constructor Create(Const IID: TGUID); // virtual;
    Destructor Destroy; override;
    { Inherited }
    function Supports(IID: TGUID): Boolean; override;
    procedure EnumKeys(Intf: IEnumKey); override;
  end;

  // 接口工厂
  TIntfFactory = Class(TBaseFactory)
  private
    Flag: Integer;
    FSvcInfoRec: TSvcInfoRec;
    FIntfCreatorFunc: TIntfCreatorFunc;
    procedure InnerGetSvcInfo(Obj: TObject; SvcInfoGetter: ISvcInfoGetter);
  protected
    procedure GetSvcInfo(Intf: ISvcInfoGetter); override;
    function GetObj(out Obj: TObject; out AutoFree: Boolean): Boolean; override;
  public
    Constructor Create(IID: TGUID; IntfCreatorFunc: TIntfCreatorFunc); virtual;
    Destructor Destroy; override;

    function GetIntf(const IID: TGUID; out Obj): HResult; override;
    procedure ReleaseIntf; override;
  end;

  // 单例工厂
  TSingletonFactory = Class(TBaseFactory)
  private
    FIntfCreatorFunc: TIntfCreatorFunc;
    FIntfRelease:Boolean;
  protected
    FInstance:TObject;
    FIntfRef:IInterface;
    procedure GetSvcInfo(Intf: ISvcInfoGetter); override;
    function GetObj(out Obj: TObject; out AutoFree: Boolean): Boolean; override;
  public
    Constructor Create(IID: TGUID; IntfCreatorFunc: TIntfCreatorFunc;IntfRelease:Boolean=False);
    destructor Destroy; override;

    function GetIntf(const IID: TGUID; out Obj): HResult; override;
    procedure ReleaseIntf; override;
  end;

  // 实例工厂
  TObjFactory = Class(TSingletonFactory)
  private
    FOwnsObj: Boolean;
  protected
  public
    Constructor Create(IID: TGUID; Instance: TObject;
      OwnsObj: Boolean = False;IntfRelease:Boolean=False);
    Destructor Destroy; override;

    //function GetIntf(const IID: TGUID; out Obj): HResult; override;
    procedure ReleaseIntf; override;
  end;

implementation

uses SysFactoryMgr, SysMsg,Dialogs;

{ TBaseFactory }

constructor TBaseFactory.Create(const IID: TGUID);
begin
  if FactoryManager.Exists(IID) then
    Raise Exception.CreateFmt(Err_IntfExists, [GUIDToString(IID)]);

  FIntfGUID := IID;
  FactoryManager.RegisterFactory(Self);
end;

destructor TBaseFactory.Destroy;
begin
  FactoryManager.UnRegisterFactory(Self);
  inherited;
end;

procedure TBaseFactory.EnumKeys(Intf: IEnumKey);
begin
  if Assigned(Intf) then
    Intf.EnumKey(GUIDToString(FIntfGUID));
end;

function TBaseFactory.Supports(IID: TGUID): Boolean;
begin
  Result := IsEqualGUID(IID, FIntfGUID);
end;

{ TIntfFactory }

constructor TIntfFactory.Create(IID: TGUID; IntfCreatorFunc: TIntfCreatorFunc);
begin
  if not Assigned(IntfCreatorFunc) then
    raise Exception.CreateFmt(Err_IntfCreatorFuncIsNil,[GUIDToString(IID)]);

  Flag := 0;
  Self.FIntfCreatorFunc := IntfCreatorFunc;
  Inherited Create(IID);
end;

function TIntfFactory.GetIntf(const IID: TGUID; out Obj): HResult;
var
  tmpObj: TObject;
begin
  Result := E_NOINTERFACE;
  if Assigned(Self.FIntfCreatorFunc) then
  begin
    tmpObj := Self.FIntfCreatorFunc(FParam);
    if tmpObj <> nil then
    begin
      if tmpObj.GetInterface(IID, Obj) then
      begin
        Result := S_OK;
        if Flag = 0 then
          InnerGetSvcInfo(tmpObj, nil);
      end;
    end;
  end;
end;

function TIntfFactory.GetObj(out Obj: TObject; out AutoFree: Boolean): Boolean;
begin
  AutoFree := True;
  Obj := Self.FIntfCreatorFunc(Self.FParam);
  Result := Obj <> nil;
end;

destructor TIntfFactory.Destroy;
begin

  inherited;
end;

procedure TIntfFactory.GetSvcInfo(Intf: ISvcInfoGetter);
var
  Obj: TObject;
begin
  if (Flag = 0) or (Flag = 2) then
  begin
    Obj:=Self.FIntfCreatorFunc(self.FParam);
    if Obj<>nil then
      InnerGetSvcInfo(Obj, Intf);
  end;
  Intf.SvcInfo(FSvcInfoRec);
end;

procedure TIntfFactory.InnerGetSvcInfo(Obj: TObject;
  SvcInfoGetter: ISvcInfoGetter);
var
  SvcInfoIntf: ISvcInfo;
  SvcInfoIntfEx: ISvcInfoEx;
begin
  FSvcInfoRec.GUID := GUIDToString(Self.FIntfGUID);
  if Obj.GetInterface(ISvcInfo, SvcInfoIntf) then
  begin
    Self.Flag := 1;
    with FSvcInfoRec do
    begin
      // GUID      :=GUIDToString(self.FIntfGUID);
      ModuleName := SvcInfoIntf.GetModuleName;
      Title := SvcInfoIntf.GetTitle;
      Version := SvcInfoIntf.GetVersion;
      Comments := SvcInfoIntf.GetComments;
    end;
  end
  else if Obj.GetInterface(ISvcInfoEx, SvcInfoIntfEx) then
  begin
    Flag := 2;
    if SvcInfoGetter <> nil then
      SvcInfoIntfEx.GetSvcInfo(SvcInfoGetter);
  end;
end;

procedure TIntfFactory.ReleaseIntf;
begin
  inherited;

end;

{ TSingletonFactory }

constructor TSingletonFactory.Create(IID: TGUID;
  IntfCreatorFunc: TIntfCreatorFunc;IntfRelease:Boolean);
begin
  FInstance        := nil;
  FIntfRef         := nil;
  FIntfRelease     := IntfRelease;
  FIntfCreatorFunc := IntfCreatorFunc;
  inherited Create(IID);
end;

function TSingletonFactory.GetIntf(const IID: TGUID; out Obj): HResult;
begin
  //if not Assigned(FIntfCreatorFunc) then//不能这样，因为后代TObjFactory时FIntfCreatorFunc为空
  //  raise Exception.CreateFmt(Err_IntfCreatorFuncIsNil,[GUIDToString(IID)]);

  Result := E_NOINTERFACE;
  if FIntfRef = nil then
  begin
    FInstance := FIntfCreatorFunc(Self.FParam);
    if FInstance <> nil then
    begin
      if FInstance.GetInterface(IID, FIntfRef) then
      begin
        Result := S_OK;
        IInterface(Obj):=FIntfRef;
      end else
        Raise Exception.CreateFmt(Err_IntfNotSupport, [GUIDToString(IID)]);
    end;
  end else begin
    Result := S_OK;
    IInterface(Obj):=FIntfRef;
  end;
end;

destructor TSingletonFactory.Destroy;
begin

  inherited;
end;

function TSingletonFactory.GetObj(out Obj: TObject;
  out AutoFree: Boolean): Boolean;
begin
  Obj := Self.FInstance;
  AutoFree := False;
  Result := True;
end;

procedure TSingletonFactory.GetSvcInfo(Intf: ISvcInfoGetter);
var
  SvcInfoIntf: ISvcInfo;
  SvcInfoIntfEx: ISvcInfoEx;
  SvcInfoRec: TSvcInfoRec;
begin
  if FInstance = nil then
  begin
    FInstance:=FIntfCreatorFunc(self.FParam);
    if FInstance=nil then exit;
  end;

  if FInstance.GetInterface(ISvcInfo, SvcInfoIntf) then
  begin
    with SvcInfoRec do
    begin
      GUID       := GUIDToString(Self.FIntfGUID);
      ModuleName := SvcInfoIntf.GetModuleName;
      Title      := SvcInfoIntf.GetTitle;
      Version    := SvcInfoIntf.GetVersion;
      Comments   := SvcInfoIntf.GetComments;
    end;
    Intf.SvcInfo(SvcInfoRec);
  end
  else if FInstance.GetInterface(ISvcInfoEx, SvcInfoIntfEx) then
    SvcInfoIntfEx.GetSvcInfo(Intf)
  else
  begin
    with SvcInfoRec do
    begin
      GUID := GUIDToString(Self.FIntfGUID);
      ModuleName := '';
      Title      := '';
      Version    := '';
      Comments   := '';
    end;
    Intf.SvcInfo(SvcInfoRec);
  end;
end;

procedure TSingletonFactory.ReleaseIntf;
begin
  if FInstance=nil then exit;

  if (FInstance is TInterfacedObject) or FIntfRelease then
    FIntfRef:=nil
  else begin
    FInstance.Free;
    FIntfRef:=nil;
  end;
  FInstance:=nil;
end;

{ TObjFactory }

constructor TObjFactory.Create(IID: TGUID; Instance: TObject;
  OwnsObj: Boolean;IntfRelease:Boolean);
var tmpIntf:IInterface;
begin
  if Instance=nil then
    raise Exception.CreateFmt(Err_InstanceIsNil,[GUIDToString(IID)]);

  if not Instance.GetInterface(IID, tmpIntf) then
    raise Exception.CreateFmt(Err_ObjNotImpIntf, [Instance.ClassName,
      GUIDToString(IID)]);

  Inherited Create(IID,nil,IntfRelease);//往上后FIntfRef会被赋为nil
  FOwnsObj := OwnsObj or IntfRelease or (Instance is TInterfacedObject);
  FInstance:= Instance;
  FIntfRef := tmpIntf;
end;

destructor TObjFactory.Destroy;
begin

  inherited;
end;

procedure TObjFactory.ReleaseIntf;
begin
  if FInstance=nil then exit;

  if FOwnsObj then
    Inherited;
end;

end.
