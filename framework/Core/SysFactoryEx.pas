{------------------------------------
  功能说明：扩展工厂
  创建日期：2010/06/08
  作者：WZW
  版权：WZW
-------------------------------------}
unit SysFactoryEx;

interface

Uses Classes,SysUtils,FactoryIntf,SvcInfoIntf;

Type
  //基类
  TBaseFactoryEx=Class(TFactory,ISvcInfoEx)
  private
    FIIDList:TStrings;
  protected
    {ISvcInfoEx}
    procedure GetSvcInfo(Intf:ISvcInfoGetter);virtual;
  public
    Constructor Create(Const IIDs:Array of TGUID);
    Destructor Destroy;override;

    {Inherited}
    function GetIntf(const IID : TGUID; out Obj):HResult;override;
    procedure ReleaseIntf;override;

    function Supports(IID:TGUID):Boolean;override;
    procedure EnumKeys(Intf:IEnumKey);override;
  end;

  TSingletonFactoryEx=Class(TBaseFactoryEx)
  private
    FIntfCreatorFunc: TIntfCreatorFunc;
    FIntfRelease:Boolean;
  protected
    FIntfRef:IInterface;
    FInstance:TObject;
    procedure GetSvcInfo(Intf:ISvcInfoGetter);override;
    function GetObj(out Obj: TObject; out AutoFree: Boolean): Boolean; override;
  public
    Constructor Create(IIDs:Array of TGUID;IntfCreatorFunc:TIntfCreatorFunc;
      IntfRelease:Boolean=False);
    destructor Destroy; override;

    function GetIntf(const IID : TGUID; out Obj):HResult; override;
    procedure ReleaseIntf;override;
  end;

  TObjFactoryEx=Class(TSingletonFactoryEx)
  private
    FOwnsObj:Boolean;
  protected
  public
    Constructor Create(Const IIDs:Array of TGUID;Instance:TObject;
      OwnsObj:Boolean=False;IntfRelease:Boolean=False);
    Destructor Destroy;override;

    {Inherited}
    //function GetIntf(const IID : TGUID; out Obj):HResult;override;
    procedure ReleaseIntf;override;
  end;
implementation

uses SysFactoryMgr,SysMsg;

{ TBaseFactoryEx }

constructor TBaseFactoryEx.Create(const IIDs: array of TGUID);
var i:Integer;
begin
  FIIDList:=TStringList.Create;
  
  for i:=low(IIDs) to high(IIDs) do
  begin
    if FactoryManager.Exists(IIDs[i]) then
      Raise Exception.CreateFmt(Err_IntfExists,[GUIDToString(IIDs[i])]);
      
    FIIDList.Add(GUIDToString(IIDs[i]));
  end;
  FactoryManager.RegisterFactory(self);
end;

function TBaseFactoryEx.GetIntf(const IID: TGUID; out Obj):HResult;
begin
  Result:=E_NOINTERFACE;
end;

destructor TBaseFactoryEx.Destroy;
begin
  FactoryManager.UnRegisterFactory(self);
  FIIDList.Free;
  inherited;
end;

procedure TBaseFactoryEx.EnumKeys(Intf: IEnumKey);
var i:Integer;
begin
  if Assigned(Intf) then
  begin
    for i := 0 to FIIDList.Count - 1 do
      Intf.EnumKey(FIIDList[i]);
  end;
end;

procedure TBaseFactoryEx.GetSvcInfo(Intf: ISvcInfoGetter);
begin

end;

procedure TBaseFactoryEx.ReleaseIntf;
begin

end;

function TBaseFactoryEx.Supports(IID: TGUID): Boolean;
begin
  Result:=FIIDList.IndexOf(GUIDToString(IID))<>-1;
end;

{ TSingletonFactoryEx }

constructor TSingletonFactoryEx.Create(IIDs: array of TGUID;
  IntfCreatorFunc: TIntfCreatorFunc;IntfRelease:Boolean);
begin
  if length(IIDs)=0 then
    raise Exception.Create(Err_IIDsParamIsEmpty);

  FInstance       :=nil;
  FIntfRef        := nil;
  FIntfRelease    :=IntfRelease;
  FIntfCreatorFunc:=IntfCreatorFunc;
  Inherited Create(IIDs);
end;

function TSingletonFactoryEx.GetIntf(const IID: TGUID; out Obj):HResult;
begin
  //if not Assigned(FIntfCreatorFunc) then//不能这样，因为后代TObjFactoryEx时FIntfCreatorFunc为空
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
    Result := FIntfRef.QueryInterface(IID,Obj);
  end;
end;

function TSingletonFactoryEx.GetObj(out Obj: TObject;
  out AutoFree: Boolean): Boolean;
begin
  Obj := Self.FInstance;
  AutoFree := False;
  Result := True;
end;

destructor TSingletonFactoryEx.Destroy;
begin

  inherited;
end;

procedure TSingletonFactoryEx.GetSvcInfo(Intf: ISvcInfoGetter);
var SvcInfoIntf:ISvcInfo;
    SvcInfoIntfEx:ISvcInfoEx;
    SvcInfoRec:TSvcInfoRec;
    i:Integer;
begin
  SvcInfoIntf:=nil;
  if FInstance=nil then
  begin
    FInstance:=FIntfCreatorFunc(self.FParam);
    if FInstance=nil then exit;
  end;

  if FInstance.GetInterface(ISvcInfoEx,SvcInfoIntfEx) then
    SvcInfoIntfEx.GetSvcInfo(Intf)
  else begin
    if FInstance.GetInterface(ISvcInfo,SvcInfoIntf) then
    begin
      with SvcInfoRec do
      begin
        //GUID      :=GUIDToString(self.FIntfGUID);
        ModuleName:=SvcInfoIntf.GetModuleName;
        Title     :=SvcInfoIntf.GetTitle;
        Version   :=SvcInfoIntf.GetVersion;
        Comments  :=SvcInfoIntf.GetComments;
      end;
    end;
    for i:=0 to self.FIIDList.Count-1 do
    begin
      SvcInfoRec.GUID:=self.FIIDList[i];
      if SvcInfoIntf=nil then
      begin
        with SvcInfoRec do
        begin
          ModuleName:='';
          Title     :='';
          Version   :='';
          Comments  :='';
        end;
      end;
      Intf.SvcInfo(SvcInfoRec);
    end;
  end;
end;

procedure TSingletonFactoryEx.ReleaseIntf;
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

{ TObjFactoryEx }

constructor TObjFactoryEx.Create(const IIDs: array of TGUID;
  Instance: TObject;OwnsObj:Boolean;IntfRelease:Boolean);
begin
  if length(IIDs)=0 then
    raise Exception.Create(Err_IIDsParamIsEmpty);

  if Instance=nil then
    raise Exception.CreateFmt(Err_InstanceIsNil,[GUIDToString(IIDs[0])]);

  Inherited Create(IIDs,nil,IntfRelease);//往上后FIntfRef会被赋为nil
  FOwnsObj := OwnsObj or IntfRelease or (Instance is TInterfacedObject);
  FInstance:= Instance;
  FInstance.GetInterface(IInterface,FIntfRef);
end;

destructor TObjFactoryEx.Destroy;
begin

  inherited;
end;

procedure TObjFactoryEx.ReleaseIntf;
begin
  if FOwnsObj then
    Inherited;
end;

end.
