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
  TIntfCreatorFunc = procedure(out anInstance: IInterface);
  //基类
  TBaseFactoryEx=Class(TInterfacedObject,ISysFactory,ISvcInfoEx)
  private
    FIIDList:TStrings;
  protected
    {ISysFactory}
    procedure CreateInstance(const IID : TGUID; out Obj);virtual;
    procedure ReleaseInstance;virtual;
    function Supports(IID:TGUID):Boolean;virtual;
    procedure EnumKeys(Intf:IEnumKey);dynamic;
    {ISvcInfoEx}
    procedure GetSvcInfo(Intf:ISvcInfoGetter);virtual;
  public
    Constructor Create(Const IIDs:Array of TGUID);
    Destructor Destroy;override;
  end;

  TObjFactoryEx=Class(TBaseFactoryEx)
  private
    FOwnsObj:Boolean;
    FInstance:TObject;
  protected
    {ISysFactory}
    procedure CreateInstance(const IID : TGUID; out Obj);override;
    procedure ReleaseInstance;override;
    {ISvcInfoEx}
    procedure GetSvcInfo(Intf:ISvcInfoGetter);override;
  public
    Constructor Create(Const IIDs:Array of TGUID;Instance:TObject;OwnsObj:Boolean=False);
    Destructor Destroy;override;
  end;

  TSingletonFactoryEx=Class(TBaseFactoryEx)
  private
    FIntfCreatorFunc: TIntfCreatorFunc;
    FInstance:IInterface;
  protected
    procedure CreateInstance(const IID : TGUID; out Obj); override;
    procedure ReleaseInstance;override;
    procedure GetSvcInfo(Intf:ISvcInfoGetter);override;
  public
    Constructor Create(IIDs:Array of TGUID;IntfCreatorFunc:TIntfCreatorFunc);
    destructor Destroy; override;
  end;

implementation

uses SysFactoryMgr;

const Err_IntfExists='接口%s已存在，不能重复注册！';
      Err_IntfNotSupport='对象不支持%s接口！';
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

procedure TBaseFactoryEx.CreateInstance(const IID: TGUID; out Obj);
begin

end;

destructor TBaseFactoryEx.Destroy;
begin
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

procedure TBaseFactoryEx.ReleaseInstance;
begin

end;

function TBaseFactoryEx.Supports(IID: TGUID): Boolean;
begin
  Result:=FIIDList.IndexOf(GUIDToString(IID))<>-1;
end;

{ TObjFactoryEx }

constructor TObjFactoryEx.Create(const IIDs: array of TGUID;
  Instance: TObject;OwnsObj:Boolean);
begin
  if Instance=nil then exit;
  if (Instance is TInterfacedObject) then
    Raise Exception.Create('不要用TObjFactoryEx注册TInterfacedObject及其子类实现的接口！');
  if length(IIDs)=0 then
    Raise Exception.Create('TObjFactoryEx注册参数IIDs不能为空！');

  FOwnsObj:=OwnsObj;
  self.FInstance:=Instance;
  Inherited Create(IIDs);
end;

procedure TObjFactoryEx.CreateInstance(const IID: TGUID; out Obj);
begin
  if not FInstance.GetInterface(IID,Obj) then
    Raise Exception.CreateFmt('不支持接口%s！',[GUIDToString(IID)]);
end;

destructor TObjFactoryEx.Destroy;
begin

  inherited;
end;

procedure TObjFactoryEx.GetSvcInfo(Intf: ISvcInfoGetter);
var SvcInfoIntf:ISvcInfo;
    SvcInfoIntfEx:ISvcInfoEx;
    SvcInfoRec:TSvcInfoRec;
    i:Integer;
begin
  SvcInfoIntf:=nil;
  if FInstance.GetInterface(ISvcInfoEx,SvcInfoIntfEx) then
    SvcInfoIntfEx.GetSvcInfo(Intf)
  else begin
    with SvcInfoRec do
    begin
      GUID      :='';
      ModuleName:='';
      Title     :='';
      Version   :='';
      Comments  :='';
    end;
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
      Intf.SvcInfo(SvcInfoRec);
    end;
  end;
end;

procedure TObjFactoryEx.ReleaseInstance;
begin
  inherited;
  if FOwnsObj then
    FreeAndNil(self.FInstance);
end;

{ TSingletonFactoryEx }

constructor TSingletonFactoryEx.Create(IIDs: array of TGUID;
  IntfCreatorFunc: TIntfCreatorFunc);
begin
  if length(IIDs)=0 then
    Raise Exception.Create('TSingletonFactoryEx注册参数IIDs不能为空！');

  FInstance:=nil;
  FIntfCreatorFunc:=IntfCreatorFunc;
  Inherited Create(IIDs);
end;

procedure TSingletonFactoryEx.CreateInstance(const IID: TGUID; out Obj);
begin
  if FInstance=nil then
    FIntfCreatorFunc(FInstance);

  if FInstance.QueryInterface(IID,Obj)<>S_OK then
    Raise Exception.CreateFmt(Err_IntfNotSupport,[GUIDToString(IID)]);
end;

destructor TSingletonFactoryEx.Destroy;
begin
  FInstance:=nil;
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
    FIntfCreatorFunc(FInstance);

  if FInstance.QueryInterface(ISvcInfoEx,SvcInfoIntfEx)=S_OK then
    SvcInfoIntfEx.GetSvcInfo(Intf)
  else begin
    if FInstance.QueryInterface(ISvcInfo,SvcInfoIntf)=S_OK then
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

procedure TSingletonFactoryEx.ReleaseInstance;
begin
  inherited;
  FInstance:=nil;
end;

end.
