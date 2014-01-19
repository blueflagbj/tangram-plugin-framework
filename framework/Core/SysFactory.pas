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
    FIntfName: string;
    { ISvcInfoEx }
    procedure GetSvcInfo(Intf: ISvcInfoGetter); virtual; abstract;
  public
    Constructor Create(Const IntfName: string); // virtual;
    Destructor Destroy; override;
    { Inherited }
    function Supports(const IntfName: string): Boolean; override;
    procedure EnumKeys(Intf: IEnumKey); override;
  end;

  // 接口工厂
  TIntfFactory = Class(TBaseFactory)
  private
    Flag: Integer;
    FSvcInfoRec: TSvcInfoRec;
    FIntfCreatorFunc: TIntfCreatorFunc;
    procedure InnerGetSvcInfo(Intf:IInterface; SvcInfoGetter: ISvcInfoGetter);
  protected
    procedure GetSvcInfo(Intf: ISvcInfoGetter); override;
    function GetObj(out Obj: TObject; out AutoFree: Boolean): Boolean; override;
  public
    Constructor Create(const IID: TGUID;IntfCreatorFunc: TIntfCreatorFunc);overload;
    Constructor Create(const IntfName: string;IntfCreatorFunc: TIntfCreatorFunc);overload;
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
    Constructor Create(const IID: TGUID; IntfCreatorFunc: TIntfCreatorFunc;
      IntfRelease:Boolean=False);overload;
    Constructor Create(const IntfName: string; IntfCreatorFunc: TIntfCreatorFunc;
      IntfRelease:Boolean=False);overload;
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
    Constructor Create(const IID: TGUID; Instance: TObject;
      OwnsObj: Boolean = False;IntfRelease:Boolean=False); overload;
    Constructor Create(const IntfName: string; Instance: TObject;
      OwnsObj: Boolean = False;IntfRelease:Boolean=False); overload;
    Destructor Destroy; override;

    //function GetIntf(const IID: TGUID; out Obj): HResult; override;
    procedure ReleaseIntf; override;
  end;

implementation

uses SysFactoryMgr, SysMsg;

{ TBaseFactory }

constructor TBaseFactory.Create(const IntfName: string);
begin
  if FactoryManager.Exists(IntfName) then
    Raise Exception.CreateFmt(Err_IntfExists, [IntfName]);

  FIntfName := IntfName;
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
    Intf.EnumKey(self.FIntfName);
end;

function TBaseFactory.Supports(const IntfName:string): Boolean;
begin
  Result := self.FIntfName=IntfName;
end;

{ TIntfFactory }

constructor TIntfFactory.Create(const IntfName: string;
  IntfCreatorFunc: TIntfCreatorFunc);
begin
  if not Assigned(IntfCreatorFunc) then
    raise Exception.CreateFmt(Err_IntfCreatorFuncIsNil,[IntfName]);

  Flag := 0;
  Self.FIntfCreatorFunc := IntfCreatorFunc;
  Inherited Create(IntfName);
end;

constructor TIntfFactory.Create(const IID: TGUID;
  IntfCreatorFunc: TIntfCreatorFunc);
begin
  self.Create(GUIDToString(IID),IntfCreatorFunc);
end;

function TIntfFactory.GetIntf(const IID: TGUID; out Obj): HResult;
var
  tmpObj: TObject;
  tmpIntf:IInterface;
begin
  Result := E_NOINTERFACE;
  if Assigned(Self.FIntfCreatorFunc) then
  begin
    tmpObj := Self.FIntfCreatorFunc(FParam);
    if tmpObj <> nil then
    begin
      if tmpObj.GetInterface(IID, tmpIntf) then
      begin
        Result := S_OK;
        IInterface(Obj):=tmpIntf;
        if Flag = 0 then
        begin
          if tmpObj.GetInterface(IInterface,tmpIntf) then
            InnerGetSvcInfo(tmpIntf, nil);
        end;
      end else tmpObj.Free;
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
  tmpIntf:IInterface;
begin
  if (Flag = 0) or (Flag = 2) then
  begin
    Obj:=Self.FIntfCreatorFunc(self.FParam);
    if Obj<>nil then
    begin
      if Obj.GetInterface(IInterface,tmpIntf) then
      begin
        InnerGetSvcInfo(tmpIntf, Intf);
        tmpIntf:=nil;
      end;
    end;
  end;
  Intf.SvcInfo(FSvcInfoRec);
end;

procedure TIntfFactory.InnerGetSvcInfo(Intf: IInterface;
  SvcInfoGetter: ISvcInfoGetter);
var
  SvcInfoIntf: ISvcInfo;
  SvcInfoIntfEx: ISvcInfoEx;
begin
  if Intf=nil then exit;
  
  FSvcInfoRec.GUID := self.FIntfName;
  if Intf.QueryInterface(ISvcInfo, SvcInfoIntf)=S_OK then
  begin
    Self.Flag := 1;
    with FSvcInfoRec do
    begin
      // GUID      :=GUIDToString(self.FIntfGUID);
      ModuleName := SvcInfoIntf.GetModuleName;
      Title      := SvcInfoIntf.GetTitle;
      Version    := SvcInfoIntf.GetVersion;
      Comments   := SvcInfoIntf.GetComments;
    end;
    SvcInfoIntf:=nil;
  end
  else if Intf.QueryInterface(ISvcInfoEx, SvcInfoIntfEx)=S_OK then
  begin
    Flag := 2;
    if SvcInfoGetter <> nil then
      SvcInfoIntfEx.GetSvcInfo(SvcInfoGetter);
    SvcInfoIntfEx:=nil;
  end;
end;

procedure TIntfFactory.ReleaseIntf;
begin
  inherited;

end;

{ TSingletonFactory }

constructor TSingletonFactory.Create(const IntfName: string;
  IntfCreatorFunc: TIntfCreatorFunc; IntfRelease: Boolean);
begin
  FInstance        := nil;
  FIntfRef         := nil;
  FIntfRelease     := IntfRelease;
  FIntfCreatorFunc := IntfCreatorFunc;
  inherited Create(IntfName);
end;

constructor TSingletonFactory.Create(const IID: TGUID;
  IntfCreatorFunc:TIntfCreatorFunc;IntfRelease:Boolean);
begin
  self.Create(GUIDToString(IID),IntfCreatorFunc,IntfRelease);
end;

function TSingletonFactory.GetIntf(const IID: TGUID; out Obj): HResult;
begin
  //if not Assigned(FIntfCreatorFunc) then//不能这样，因为后代TObjFactory时FIntfCreatorFunc为空
  //  raise Exception.CreateFmt(Err_IntfCreatorFuncIsNil,[GUIDToString(IID)]);

  Result := E_NOINTERFACE;
  if FIntfRef = nil then
  begin
    if (FInstance=nil) and (FIntfCreatorFunc<>nil) then
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
    Result:=FIntfRef.QueryInterface(IID,Obj);
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
    FInstance.GetInterface(IInterface,FIntfRef);
  end;

  if FInstance.GetInterface(ISvcInfo, SvcInfoIntf) then
  begin
    with SvcInfoRec do
    begin
      GUID       := Self.FIntfName;
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
      GUID := Self.FIntfName;
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

constructor TObjFactory.Create(const IntfName: string; Instance: TObject;
  OwnsObj, IntfRelease: Boolean);
begin
  if Instance=nil then
    raise Exception.CreateFmt(Err_InstanceIsNil,[IntfName]);

  Inherited Create(IntfName,nil,IntfRelease);//往上后FIntfRef会被赋为nil
  FOwnsObj := OwnsObj or IntfRelease or (Instance is TInterfacedObject);
  FInstance:= Instance;
  //Instance.GetInterface(IInterface, FIntfRef)
end;

constructor TObjFactory.Create(const IID: TGUID; Instance: TObject;
  OwnsObj: Boolean;IntfRelease:Boolean);
var IIDStr:String;
    tmpIntf:IInterface;
begin
  IIDStr:=GUIDToString(IID);
  if not Instance.GetInterface(IID, tmpIntf) then
    raise Exception.CreateFmt(Err_ObjNotImpIntf, [Instance.ClassName,
      IIDStr]);

  self.Create(IIDStr,Instance,OwnsObj,IntfRelease);
  FIntfRef:=tmpIntf;
end;


destructor TObjFactory.Destroy;
begin

  inherited;
end;

procedure TObjFactory.ReleaseIntf;
begin
  if FOwnsObj then
    Inherited;
end;

end.
