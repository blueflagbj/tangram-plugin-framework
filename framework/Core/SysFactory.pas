{------------------------------------
  功能说明：工厂
  创建日期：2010/03/29
  作者：WZW
  版权：WZW
-------------------------------------}
unit SysFactory;

interface

Uses Classes,SysUtils,FactoryIntf,SvcInfoIntf;

Type
  TIntfCreatorFunc = procedure(out anInstance: IInterface);
  //工厂基类
  TBaseFactory=Class(TFactory,ISvcInfoEx)
  private
  protected
    FIntfGUID:TGUID;
    {ISvcInfoEx}
    procedure GetSvcInfo(Intf:ISvcInfoGetter);virtual;abstract;
  public
    Constructor Create(Const IID:TGUID);//virtual;
    Destructor Destroy;override;

    {Inherited}
    function Supports(IID:TGUID):Boolean;override;
    procedure EnumKeys(Intf:IEnumKey);override;
  end;

  //接口工厂
  TIntfFactory=Class(TBaseFactory)
  private
    Flag:Integer;
    FSvcInfoRec:TSvcInfoRec;
    FIntfCreatorFunc:TIntfCreatorFunc;
    procedure InnerGetSvcInfo(Intf:IInterface;SvcInfoGetter: ISvcInfoGetter);
  protected
    procedure GetSvcInfo(Intf:ISvcInfoGetter);override;
  public
    Constructor Create(IID:TGUID;IntfCreatorFunc:TIntfCreatorFunc);virtual;
    Destructor Destroy;override;

    procedure CreateInstance(const IID : TGUID; out Obj); override;
     procedure ReleaseInstance;override;
  end;

  //单例工厂
  TSingletonFactory=Class(TIntfFactory)
  private
    FInstance:IInterface;
  protected
    procedure GetSvcInfo(Intf:ISvcInfoGetter);override;
  public
    Constructor Create(IID:TGUID;IntfCreatorFunc:TIntfCreatorFunc);override;
    destructor Destroy; override;

    procedure CreateInstance(const IID : TGUID; out Obj); override;
    procedure ReleaseInstance;override;
  end;
  //实例工厂
  TObjFactory=Class(TBaseFactory)
  private
    FOwnsObj:Boolean;
    FInstance:TObject;
    FRefIntf:IInterface;
  protected
    procedure GetSvcInfo(Intf:ISvcInfoGetter);override;

  public
    Constructor Create(IID:TGUID;Instance:TObject;OwnsObj:Boolean=False);
    Destructor Destroy;override;

    procedure CreateInstance(const IID : TGUID; out Obj); override;
    procedure ReleaseInstance;override;
  end;
  
implementation

uses SysFactoryMgr,SysMsg;

{ TBaseFactory }

constructor TBaseFactory.Create(const IID: TGUID);
begin
  if FactoryManager.Exists(IID) then
    Raise Exception.CreateFmt(Err_IntfExists,[GUIDToString(IID)]);

  FIntfGUID:=IID;
  FactoryManager.RegisterFactory(Self);
end;

destructor TBaseFactory.Destroy;
begin
  FactoryManager.UnRegisterFactory(self);
  inherited;
end;

procedure TBaseFactory.EnumKeys(Intf: IEnumKey);
begin
  if Assigned(Intf) then
    Intf.EnumKey(GUIDToString(FIntfGUID));
end;

function TBaseFactory.Supports(IID: TGUID): Boolean;
begin
  Result:=IsEqualGUID(IID,FIntfGUID);
end;

{ TIntfFactory }

constructor TIntfFactory.Create(IID: TGUID; IntfCreatorFunc:TIntfCreatorFunc);
begin
  Flag:=0;
  self.FIntfCreatorFunc:=IntfCreatorFunc;
  Inherited Create(IID);
end;

procedure TIntfFactory.CreateInstance(const IID: TGUID; out Obj);
var tmpIntf:IInterface;
begin
  self.FIntfCreatorFunc(tmpIntf);
  tmpIntf.QueryInterface(IID,Obj);
  if Flag=0 then
    InnerGetSvcInfo(tmpIntf,nil);
end;

destructor TIntfFactory.Destroy;
begin

  inherited;
end;

procedure TIntfFactory.GetSvcInfo(Intf: ISvcInfoGetter);
var tmpIntf:IInterface;
begin
  if (Flag=0) or (Flag=2) then
  begin
    self.FIntfCreatorFunc(tmpIntf);
    InnerGetSvcInfo(tmpIntf,Intf);
  end;
  Intf.SvcInfo(FSvcInfoRec);
end;

procedure TIntfFactory.InnerGetSvcInfo(Intf:IInterface;SvcInfoGetter: ISvcInfoGetter);
var SvcInfoIntf:ISvcInfo;
    SvcInfoIntfEx:ISvcInfoEx;
begin
  FSvcInfoRec.GUID:=GUIDToString(self.FIntfGUID);
  if Intf.QueryInterface(ISvcInfo,SvcInfoIntf)=S_OK then
  begin
    self.Flag:=1;
    with FSvcInfoRec do
    begin
      //GUID      :=GUIDToString(self.FIntfGUID);
      ModuleName:=SvcInfoIntf.GetModuleName;
      Title     :=SvcInfoIntf.GetTitle;
      Version   :=SvcInfoIntf.GetVersion;
      Comments  :=SvcInfoIntf.GetComments;
    end;
  end else if Intf.QueryInterface(ISvcInfoEx,SvcInfoIntfEx)=S_OK then
  begin
    Flag:=2;
    if SvcInfoGetter<>nil then
      SvcInfoIntfEx.GetSvcInfo(SvcInfoGetter);
  end;
end;

procedure TIntfFactory.ReleaseInstance;
begin

end;

{ TSingletonFactory }

constructor TSingletonFactory.Create(IID: TGUID;
  IntfCreatorFunc:TIntfCreatorFunc);
begin
  FInstance:=nil;
  inherited Create(IID,IntfCreatorFunc);
end;

procedure TSingletonFactory.CreateInstance(const IID: TGUID;out Obj);
begin
  if FInstance=nil then
    Inherited Createinstance(IID,FInstance);
    
  if FInstance.QueryInterface(IID,Obj)<>S_OK then
    Raise Exception.CreateFmt(Err_IntfNotSupport,[GUIDToString(IID)]);
end;

destructor TSingletonFactory.Destroy;
begin
  FInstance:=nil;
  inherited;
end;

procedure TSingletonFactory.GetSvcInfo(Intf: ISvcInfoGetter);
var SvcInfoIntf:ISvcInfo;
    SvcInfoIntfEx:ISvcInfoEx;
    SvcInfoRec:TSvcInfoRec;
begin
  if FInstance=nil then
    Inherited Createinstance(self.FIntfGUID,FInstance);

  if FInstance.QueryInterface(ISvcInfo,SvcInfoIntf)=S_OK then
  begin
    with SvcInfoRec do
    begin
      GUID      :=GUIDToString(self.FIntfGUID);
      ModuleName:=SvcInfoIntf.GetModuleName;
      Title     :=SvcInfoIntf.GetTitle;
      Version   :=SvcInfoIntf.GetVersion;
      Comments  :=SvcInfoIntf.GetComments;
    end;
    Intf.SvcInfo(SvcInfoRec);
  end else if FInstance.QueryInterface(ISvcInfoEx,SvcInfoIntfEx)=S_OK then
    SvcInfoIntfEx.GetSvcInfo(Intf)
  else begin
    with SvcInfoRec do
    begin
      GUID      :=GUIDToString(self.FIntfGUID);
      ModuleName:='';
      Title     :='';
      Version   :='';
      Comments  :='';
    end;
    Intf.SvcInfo(SvcInfoRec);
  end;
end;

procedure TSingletonFactory.ReleaseInstance;
var obj:TComponent;
    RefIntf:IInterfaceComponentReference;
begin
  if FInstance<>nil then
  begin
    if FInstance.QueryInterface(IInterfaceComponentReference,RefIntf)=S_OK then
    begin
      obj:=RefIntf.GetComponent;
      obj.Free;
    end;
    FInstance:=nil;
  end;
end;

{ TObjFactory }

constructor TObjFactory.Create(IID: TGUID; Instance: TObject;OwnsObj:Boolean);
begin
  if not Instance.GetInterface(IID,FRefIntf) then
    Raise Exception.CreateFmt(Err_ObjNotImpIntf,[Instance.ClassName,GUIDToString(IID)]);

  if (Instance is TInterfacedObject) then
    Raise Exception.Create(Err_DontUseTInterfacedObject);

  FOwnsObj:=OwnsObj;
  FInstance:=Instance;
  Inherited Create(IID);
end;

procedure TObjFactory.CreateInstance(const IID: TGUID;out Obj);
begin
  IInterface(Obj):=FRefIntf;
end;

destructor TObjFactory.Destroy;
begin

  inherited;
end;

procedure TObjFactory.GetSvcInfo(Intf: ISvcInfoGetter);
var SvcInfoIntf:ISvcInfo;
    SvcInfoIntfEx:ISvcInfoEx;
    SvcInfoRec:TSvcInfoRec;
begin
  if FInstance=nil then
    Inherited Createinstance(self.FIntfGUID,FInstance);

  if FInstance.GetInterface(ISvcInfo,SvcInfoIntf) then
  begin
    with SvcInfoRec do
    begin
      GUID      :=GUIDToString(self.FIntfGUID);
      ModuleName:=SvcInfoIntf.GetModuleName;
      Title     :=SvcInfoIntf.GetTitle;
      Version   :=SvcInfoIntf.GetVersion;
      Comments  :=SvcInfoIntf.GetComments;
    end;
    Intf.SvcInfo(SvcInfoRec);
  end else if FInstance.GetInterface(ISvcInfoEx,SvcInfoIntfEx) then
    SvcInfoIntfEx.GetSvcInfo(Intf)
  else begin
    with SvcInfoRec do
    begin
      GUID      :=GUIDToString(self.FIntfGUID);
      ModuleName:='';
      Title     :='';
      Version   :='';
      Comments  :='';
    end;
    Intf.SvcInfo(SvcInfoRec);
  end;
end;

procedure TObjFactory.ReleaseInstance;
begin
  inherited;
  FRefIntf:=nil;
  if FOwnsObj then
    FreeAndNil(FInstance);
end;

end.
