{------------------------------------
  功能说明：系统通知服务
  创建日期：2011/07/16
  作者：wzw
  版权：wzw
-------------------------------------}
unit SysNotifyService;

interface

uses SysUtils,Classes,uIntfObj,NotifyServiceIntf,SvcInfoIntf;

Type
  TNotifyObj=Class(TObject)
  public
    procedure SendNotify(Flags: Integer; Intf: IInterface;Param:Integer);virtual;abstract;
  End;
  ////////////////////////////////////////////
  TIntfNotify=Class(TNotifyObj)
  private
    FNotifyIntf:INotify;
  public
    procedure SendNotify(Flags: Integer; Intf: IInterface;Param:Integer);override;
    Constructor Create(Notify:INotify);
    Destructor Destroy;override;
  End;
  ////////////////////////////////////////////
  TIntfNotifyEx=Class(TIntfNotify)
  private
    FFlags:Integer;
  public
    procedure SendNotify(Flags: Integer; Intf: IInterface;Param:Integer);override;
    Constructor Create(Flags:Integer;Notify:INotify);
  End;
  ////////////////////////////////////////////
  TEventNotify=Class(TNotifyObj)
  private
    FNotifyEvent:TNotifyEvent;
  public
    procedure SendNotify(Flags: Integer; Intf: IInterface;Param:Integer);override;
    Constructor Create(NotifyEvent:TNotifyEvent);
  End;
  ////////////////////////////////////////////
  TEventNotifyEx=Class(TEventNotify)
  private
    FFlags:Integer;
  public
    procedure SendNotify(Flags: Integer; Intf: IInterface;Param:Integer);override;
    Constructor Create(Flags:Integer;NotifyEvent:TNotifyEvent);
  End;
  ///////////////////////////////////////////


  TNotifyService=Class(TIntfObj,INotifyService,ISvcInfo)
  private
    FList:TStrings;
    Factory:TObject;
    procedure RegNotify(ID:Integer;NotifyObj:TNotifyObj);
    procedure UnRegNotify(ID:Integer);
    procedure WriteErrFmt(const err: String; const Args: array of const );
  protected
  {INotifyService}
    procedure SendNotify(Flags: Integer; Intf: IInterface;Param:Integer);

    procedure RegisterNotify(Notify:INotify);
    procedure UnRegisterNotify(Notify:INotify);

    procedure RegisterNotifyEx(Flags:Integer;Notify:INotify);
    procedure UnRegisterNotifyEx(Notify:INotify);

    procedure RegisterNotifyEvent(NotifyEvent:TNotifyEvent);
    procedure UnRegisterNotifyEvent(NotifyEvent:TNotifyEvent);

    procedure RegisterNotifyEventEx(Flags: Integer;NotifyEvent:TNotifyEvent);
    procedure UnRegisterNotifyEventEx(NotifyEvent:TNotifyEvent);
    {ISvcInfo}
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;
  public
    Constructor Create;
    Destructor Destroy;override;
  End;

implementation

uses SysSvc,LogIntf,SysMsg,SysFactory;

{ TNotifyService }

function TNotifyService.GetComments: String;
begin
  Result:='注册、发送通知，用于模块之间通讯。';
end;

function TNotifyService.GetModuleName: String;
begin
  Result := ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TNotifyService.GetTitle: String;
begin
  Result:='系统通知服务接口(INotifyService)';
end;

function TNotifyService.GetVersion: String;
begin
  Result:='20110716.001';
end;

constructor TNotifyService.Create;
begin
  FList:=TStringList.Create;

  Factory:=TObjFactory.Create(INotifyService,self);
end;

destructor TNotifyService.Destroy;
var i:Integer;
begin
  for i := 0 to FList.Count - 1 do
    FList.Objects[i].Free;

  FList.Free;
  Factory.Free;
  inherited;
end;

procedure TNotifyService.RegNotify(ID: Integer; NotifyObj: TNotifyObj);
begin
  FList.AddObject(IntToStr(ID),NotifyObj);
end;

procedure TNotifyService.UnRegNotify(ID: Integer);
var idx:Integer;
begin
  idx:=FList.IndexOf(IntToStr(ID));
  if idx<>-1 then
  begin
    FList.Objects[idx].Free;
    FList.Delete(idx);
  end;
end;

procedure TNotifyService.WriteErrFmt(const err: String;
  const Args: array of const);
var
  Log: ILog;
begin
  if SysService.QueryInterface(ILog, Log) = S_OK then
    Log.WriteLogFmt(err, Args);
end;

procedure TNotifyService.RegisterNotify(Notify: INotify);
begin
  self.RegNotify(Integer(Pointer(Notify)),TIntfNotify.Create(Notify));
end;

procedure TNotifyService.RegisterNotifyEvent(NotifyEvent: TNotifyEvent);
begin
  self.RegNotify(Integer(@NotifyEvent),TEventNotify.Create(NotifyEvent));
end;

procedure TNotifyService.RegisterNotifyEventEx(Flags: Integer;
  NotifyEvent: TNotifyEvent);
begin
  self.RegNotify(Integer(@NotifyEvent),TEventNotifyEx.Create(Flags,NotifyEvent));
end;

procedure TNotifyService.RegisterNotifyEx(Flags: Integer; Notify: INotify);
begin
  self.RegNotify(Integer(Pointer(Notify)),TIntfNotifyEx.Create(Flags,Notify));
end;

procedure TNotifyService.SendNotify(Flags: Integer; Intf: IInterface;Param:Integer);
var i:Integer;
    NotifyObj:TNotifyObj;
begin
  for i := 0 to FList.Count - 1 do
  begin
    NotifyObj:=TNotifyObj(FList.Objects[i]);
    try
      NotifyObj.SendNotify(Flags,Intf,Param);
    Except
      on E: Exception do
        WriteErrFmt(Err_ModuleNotify,[E.Message]);
    end;
  end;
end;

procedure TNotifyService.UnRegisterNotify(Notify: INotify);
begin
  self.UnRegNotify(Integer(Pointer(Notify)));
end;

procedure TNotifyService.UnRegisterNotifyEx(Notify: INotify);
begin
  self.UnRegisterNotify(Notify);
end;

procedure TNotifyService.UnRegisterNotifyEvent(NotifyEvent: TNotifyEvent);
begin
  self.UnRegNotify(Integer(@NotifyEvent));
end;

procedure TNotifyService.UnRegisterNotifyEventEx(NotifyEvent: TNotifyEvent);
begin
  self.UnRegisterNotifyEvent(NotifyEvent);
end;

{ TIntfNotify }

constructor TIntfNotify.Create(Notify: INotify);
begin
  self.FNotifyIntf:=Notify;
end;

destructor TIntfNotify.Destroy;
begin
  FNotifyIntf:=nil;
  inherited;
end;

procedure TIntfNotify.SendNotify(Flags: Integer; Intf: IInterface;Param:Integer);
begin
  if FNotifyIntf<>nil then
    FNotifyIntf.Notify(Flags,Intf,Param);
end;

{ TIntfNotifyEx }

constructor TIntfNotifyEx.Create(Flags: Integer; Notify: INotify);
begin
  self.FFlags:=Flags;
  Inherited Create(Notify);
end;

procedure TIntfNotifyEx.SendNotify(Flags: Integer; Intf: IInterface;Param:Integer);
begin
  if Flags=self.FFlags then
    inherited;
end;

{ TEventNotify }

constructor TEventNotify.Create(NotifyEvent: TNotifyEvent);
begin
  self.FNotifyEvent:=NotifyEvent;
end;

procedure TEventNotify.SendNotify(Flags: Integer; Intf: IInterface;Param:Integer);
begin
  if Assigned(FNotifyEvent) then
    FNotifyEvent(Flags,Intf,Param);
end;

{ TEventNotifyEx }

constructor TEventNotifyEx.Create(Flags: Integer; NotifyEvent: TNotifyEvent);
begin
  self.FFlags:=Flags;
  Inherited Create(NotifyEvent);
end;

procedure TEventNotifyEx.SendNotify(Flags: Integer; Intf: IInterface;Param:Integer);
begin
  if self.FFlags=Flags then
    inherited;
end;

initialization

finalization

end.
