{------------------------------------
  功能说明：菜单管理...
  创建日期：2010/04/23
  作者：wzw
  版权：wzw
-------------------------------------}
unit MenuDispatcher;

interface

uses SysUtils,Classes,Graphics,ComCtrls,Menus,Contnrs,MenuEventBinderIntf,
     SvcInfoIntf,RegIntf,MainFormIntf;

Type
  TItem=Class(TObject)
    Key:String;
    Obj:TObject;
    Event:TNotifyEvent;
  end;
  
  TMenuDispatcher=Class(TObject,IMenuEventBinder,ISvcInfo)
  private
    FList:TObjectList;
    procedure CreateMenu;
    procedure CreateTool;
    procedure OnClick(Sender:TObject);
  protected
    {IInterface}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    {IMenuEventBinder}
    procedure RegMenuEvent(const Key:String;MenuClick:TNotifyEvent);
    procedure RegToolEvent(const Key:String;ToolClick:TNotifyEvent;Img:TGraphic);
    {ISvcInfo}
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;
  public
    Constructor Create;
    Destructor Destroy;override;
  end;

implementation

uses SysSvc,SysFactory;//SplashFormIntf

const MenuKey='SYSTEM\MENU';
      ToolKey='SYSTEM\TOOL';
{ TMenuDispatcher }

function TMenuDispatcher.GetComments: String;
begin
  Result:='可以给菜单或工具栏按扭绑定事件。';
end;

function TMenuDispatcher.GetModuleName: String;
begin
  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TMenuDispatcher.GetTitle: String;
begin
  Result:='菜单事件绑定接口(IMenuEventBinder)';
end;

function TMenuDispatcher.GetVersion: String;
begin
  Result:='20100423.001';
end;

procedure TMenuDispatcher.RegMenuEvent(const Key: String;
  MenuClick: TNotifyEvent);
var i:Integer;
    aItem:TItem;
begin
  for i:=0 to FList.Count-1 do
  begin
    aItem:=TItem(FList[i]);
    if CompareText(aItem.key,Key)=0 then
    begin
      aItem.Event:=MenuClick;
      TMenuItem(aItem.Obj).Visible:=True;
      exit;
    end;
  end;
end;

constructor TMenuDispatcher.Create;
begin
  FList:=TObjectList.Create(True);
  self.CreateMenu;
  self.CreateTool;
  inherited;
end;

destructor TMenuDispatcher.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TMenuDispatcher.CreateMenu;
var Reg:IRegistry;
    aList:TStrings;
    i:Integer;
    aItem:TItem;
    vName:string;
    vStr:WideString;
    MainForm:IMainForm;
begin
  if SysService.QueryInterface(IRegistry,Reg)=S_OK then
  begin
    if Reg.OpenKey(MenuKey) then
    begin
      MainForm:=SysService as IMainForm;
      aList:=TStringList.Create;
      try
        Reg.GetValueNames(aList);
        for i:=0 to aList.Count-1 do
        begin
          vName:=aList[i];
          if Reg.ReadString(vName,vStr) then
          begin
            aItem:=TItem.Create;
            aItem.Key:=vName;
            aItem.Obj:=MainForm.CreateMenu(vStr,self.OnClick);
            TMenuItem(aItem.Obj).Visible:=False;
            aItem.Event:=nil;
            FList.Add(aItem);
          end;
        end;
      finally
        aList.Free;
      end;
    end;
  end;
end;

procedure TMenuDispatcher.OnClick(Sender: TObject);
var i:Integer;
    aItem:TItem;
begin
  for i:=0 to FList.Count-1 do
  begin
    aItem:=TItem(FList[i]);
    if aItem.Obj=Sender then
    begin
      if Assigned(aItem.Event) then
        aItem.Event(Sender);
    end;
  end;
end;

procedure TMenuDispatcher.RegToolEvent(const Key: String;
  ToolClick: TNotifyEvent; Img: TGraphic);
var i:Integer;
    aItem:TItem;
    ImgIndex:Integer;
begin
  for i:=0 to FList.Count-1 do
  begin
    aItem:=TItem(FList[i]);
    if CompareText(aItem.key,Key)=0 then
    begin
      aItem.Event:=ToolClick;
      if aItem.Obj is TToolButton then
      begin
        ImgIndex:=(SysService as IMainForm).AddImage(Img);
        TToolButton(aItem.Obj).ImageIndex:=ImgIndex;
        //TToolButton(aItem.Obj).Visible:=True;
      end;
      exit;
    end;
  end;
end;

procedure TMenuDispatcher.CreateTool;
var Reg:IRegistry;
    aList,vList:TStrings;
    i:Integer;
    aItem:TItem;
    vName,aStr:string;
    vStr:WideString;
    MainForm:IMainForm;
begin
  if SysService.QueryInterface(IRegistry,Reg)=S_OK then
  begin
    if Reg.OpenKey(ToolKey) then
    begin
      MainForm:=SysService as IMainForm;
      aList:=TStringList.Create;
      vList:=TStringList.Create;
      try
        Reg.GetValueNames(aList);
        for i:=0 to aList.Count-1 do
        begin
          vName:=aList[i];
          if Reg.ReadString(vName,vStr) then
          begin
            aStr:=vStr;
            vList.Clear;
            ExtractStrings([','],[],pchar(aStr),vList);
            aItem:=TItem.Create;
            aItem.Key:=vName;
            aItem.Obj:=MainForm.CreateToolButton(vList.Values['Caption'],self.OnClick,vList.Values['Hint']);
            //if TToolButton(aItem.Obj).Caption<>'' then//不是分隔线就先不显示,等绑定事件再显示
            //  TToolButton(aItem.Obj).Visible:=False
            //else TToolButton(aItem.Obj).Width:=8;
            aItem.Event:=nil;
            FList.Add(aItem);
          end;
        end;
      finally
        aList.Free;
        vList.Free;
      end;
    end;
  end;
end;

function TMenuDispatcher._AddRef: Integer;
begin
  Result:=-1;
end;

function TMenuDispatcher._Release: Integer;
begin
  Result:=-1;
end;

function TMenuDispatcher.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

initialization
  
finalization

end.
