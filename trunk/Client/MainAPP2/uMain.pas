{------------------------------------
  功能说明：平台主窗体
  创建日期：2008/11/17
  作者：wzw
  版权：wzw
-------------------------------------}
unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,MainFormIntf, Menus, ExtCtrls, ComCtrls, ToolWin, Buttons,SvcInfoIntf,
  ImgList, StdCtrls;

Const Msg_ClosePage=WM_USER+100;

type
  PShortCutItem=^RShortCutItem;
  RShortCutItem=Record
    aCaption:String[255];
    onClick:TShortCutClick;
  End;

  Tfrm_Main = class(TForm,IMainForm,IFormMgr,IShortCutClick,ISvcInfoEx)
    MainMenu: TMainMenu;
    StatusBar: TStatusBar;
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    Page_Form: TPageControl;
    ts_Default: TTabSheet;
    lv_ShortcutItem: TListView;
    Splitter1: TSplitter;
    pnl_ShortCutView: TPanel;
    Img32: TImageList;
    pMenu_CloseForm: TPopupMenu;
    N1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lv_ShortcutItemSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure lv_ShortcutItemGetImageIndex(Sender: TObject;
      Item: TListItem);
    procedure N1Click(Sender: TObject);
    procedure Page_FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FCurShortCutPanel:TCustomFrame;
    FShortCutList:TList;
    procedure ShowShortCutForm;
    procedure HandleException(Sender: TObject; E: Exception);

    procedure RegShotcutItem(PItem:PShortCutItem);
    function FindTab(const tabName:string):TTabSheet;
    procedure CloseActivePage;

    procedure ClosePage(var Message: TMessage); message Msg_ClosePage;
  protected
    {IMainForm}
    //注册普通菜单
    function CreateMenu(const Path:string;MenuClick:TNotifyEvent):TObject;
    //取消注册菜单
    procedure DeleteMenu(Const Path:string);
    //创建工具栏
    function CreateToolButton(const aCaption:String;onClick:TNotifyEvent;Hint:String=''):TObject;
    //注册快捷菜单
    procedure RegShortCut(const aCaption:string;onClick:TShortCutClick);
    //显示状态
    procedure ShowStatus(PnlIndex:Integer;const Msg:string);
    //退出程序
    procedure ExitApplication;
    //给ImageList添加图标
    function AddImage(Img:TGraphic):Integer;
    {IFormMgr}
    function FindForm(const FormClassName:string):TForm;
    function CreateForm(FormClass:TFormClass;SingleInstance:Boolean=True):TForm;
    procedure CloseForm(aForm:TForm);
    {ISvrInfoEx}
    procedure GetSvcInfo(Intf:ISvcInfoGetter);
    {IShortCutClick}
    //注册快捷菜单面板
    procedure RegPanel(FrameClass:TCustomFrameClass);
  public

  end;

  ERegShortCutException=Class(Exception);
var
  frm_Main: Tfrm_Main;

implementation

uses ExceptionHandle;
{$R *.dfm}

{ Tfrm_Main }

procedure Tfrm_Main.GetSvcInfo(Intf: ISvcInfoGetter);
var SvcInfo:TSvcInfoRec;
begin
  SvcInfo.ModuleName:=ExtractFileName(ParamStr(0));
  SvcInfo.GUID:=GUIDToString(IMainForm);
  SvcInfo.Title:='主窗体接口(IMainForm)';
  SvcInfo.Version:='20100421.001';
  SvcInfo.Comments:='封装一些主窗体的操作，比如创建菜单、在状态显示信息或退出系统等。';
  Intf.SvcInfo(SvcInfo);

  SvcInfo.GUID:=GUIDToString(IFormMgr);
  SvcInfo.Title:='窗体管理接口(IFormMgr)';
  SvcInfo.Version:='20100421.001';
  SvcInfo.Comments:='封装一些窗体的操作，比如新建一个窗体，查找已创建的窗体等。';
  Intf.SvcInfo(SvcInfo);
end;

function Tfrm_Main.CreateForm(FormClass: TFormClass;SingleInstance:Boolean=True): TForm;
var Form:TForm;
    tab:TTabSheet;
begin
  Result:=nil;
  tab:=self.FindTab(FormClass.ClassName);

  if not assigned(tab) then
  begin
    tab:=TTabSheet.Create(nil);
    tab.PageControl:=self.Page_Form;
    Form:=FormClass.Create(nil);
    Form.FormStyle:=fsNormal;
    Form.Parent:=tab;
    Form.BorderStyle:=bsNone;
    Form.Align:=alClient;
    Form.Show;
    tab.Name:=FormClass.ClassName;
    tab.Caption:=Form.Caption;
    tab.Tag:=Integer(Form);
    Result:=Form;
  end;
  self.Page_Form.ActivePage:=tab;
end;

procedure Tfrm_Main.ExitApplication;
begin
  self.Close;
end;

function Tfrm_Main.FindForm(const FormClassName: string): TForm;
var tab:TTabSheet;
begin
  Result:=nil;
  tab:=self.FindTab(FormClassName);
  if Assigned(tab) then
    Result:=TForm(tab.Tag);
end;


procedure Tfrm_Main.FormCreate(Sender: TObject);
begin
  FCurShortCutPanel:=nil;
  Application.OnException:=HandleException;
  FShortCutList:=TList.Create;
end;

procedure Tfrm_Main.FormDestroy(Sender: TObject);
var i:integer;
begin
  for i := 0 to FShortCutList.Count - 1 do
    disPose(PShortCutItem(FShortCutList[i]));

  FShortCutList.Free;
end;

procedure Tfrm_Main.FormShow(Sender: TObject);
begin
  ShowShortCutForm;
end;

procedure Tfrm_Main.HandleException(Sender: TObject; E: Exception);
begin
  frm_Exception:=Tfrm_Exception.Create(nil);
  try
    frm_Exception.ExceptionClass:=E.ClassName;
    if Sender.InheritsFrom(TComponent) then
      frm_Exception.SourceClass:=TComponent(Sender).Name;
    frm_Exception.ExceptionMsg:=E.Message;
    frm_Exception.ShowModal;
  finally
    frm_Exception.Free;
  end;
end;

function Tfrm_Main.CreateMenu(const Path: string; MenuClick: TNotifyEvent):TObject;
var aList:TStrings;
    newItem:TMenuItem;
  function CreateMenuItem(aList:TStrings):TMenuItem;
  var i:integer;
      pItem,aItem:TMenuItem;
      itemCaption:string;
  begin
    aItem:=nil;
    pItem:=MainMenu.Items;
    for i := 0 to aList.count - 1 do
    begin
      itemCaption:=aList[i];
      aItem:=pItem.Find(itemCaption);
      if aItem=Nil then
      begin
        aItem:=TMenuItem.Create(self);
        //aItem.Name:=...
        aItem.Caption:=itemCaption;
        pItem.Add(aItem);
      end;
      pItem:=aItem;
    end;
    Result:=aItem;
  end;
begin
  Result:=nil;
  if trim(path)='' then Exit;
  aList:=TStringList.Create;
  try
    ExtractStrings(['\'],[],Pchar(Path),aList);
    newItem:=CreateMenuItem(aList);
    newItem.OnClick:=MenuClick;
    Result:=newItem;
  finally
    aList.Free;
  end;
end;

procedure Tfrm_Main.RegShortCut(const aCaption: string; onClick: TShortCutClick);
var ShortCutItem:PShortCutItem;
begin
  if trim(aCaption)='' then Exit;
  new(ShortCutItem);
  ShortCutItem^.aCaption:=ShortString(aCaption);
  ShortCutItem^.onClick:=onClick;
  FShortCutList.Add(ShortCutItem);
end;

procedure Tfrm_Main.ShowShortCutForm;
var i:integer;
begin
  for i := 0 to FShortCutList.Count - 1 do
    self.RegShotcutItem(PShortCutItem(FShortCutList[i]));
end;

procedure Tfrm_Main.ShowStatus(PnlIndex:Integer;const Msg: string);
begin
  if (PnlIndex>=0) and (PnlIndex<StatusBar.Panels.Count-1) then
    StatusBar.Panels[PnlIndex].Text:=msg;
end;

procedure Tfrm_Main.DeleteMenu(const Path: string);
begin
  //
end;

function Tfrm_Main.AddImage(Img: TGraphic): Integer;
begin
  Result:=-1;
  if Img=nil then exit;
  if Img is TBitmap then
    Result:=self.ImageList1.Add(TBitmap(Img),TBitmap(Img))
  else if Img is TIcon then
    Result:=self.ImageList1.AddIcon(TIcon(Img));
end;

function Tfrm_Main.CreateToolButton(const aCaption: String;
  onClick: TNotifyEvent; Hint: String):TObject;
var ToolButton:TToolButton;
begin
  ToolButton:=TToolButton.Create(self);
  ToolButton.Parent:=self.ToolBar1;
  ToolButton.Left:=ToolBar1.Buttons[ToolBar1.ButtonCount-1].Left+ToolBar1.Buttons[ToolBar1.ButtonCount-1].Width;
  if aCaption='-' then//是分隔
  begin
    ToolButton.Style:=tbsDivider;
    ToolButton.Width:=8;
  end else begin
    ToolButton.Caption:=aCaption;
    ToolButton.OnClick:=onClick;
    if Hint<>'' then
    begin
      ToolButton.ShowHint:=True;
      ToolButton.Hint:=Hint;
    end;
  end;
  Result:=ToolButton;
end;

procedure Tfrm_Main.RegPanel(FrameClass: TCustomFrameClass);
begin
  if assigned(FrameClass) then
  begin
    FCurShortCutPanel:=FrameClass.Create(nil);
    FCurShortCutPanel.Parent:=pnl_ShortCutView;
    FCurShortCutPanel.Align:=alClient;
    FCurShortCutPanel.Visible:=True;
  end;
end;

procedure Tfrm_Main.RegShotcutItem(PItem: PShortCutItem);
var newItem:TListItem;
begin
  if assigned(PItem) then
  begin
    newItem:=self.lv_ShortcutItem.Items.Add;
    newItem.Caption:=String(PItem^.aCaption);
    newItem.ImageIndex:=0;
    newItem.Data:=PItem;
    //自动选择第一项
    if FCurShortCutPanel=Nil then
      newItem.Selected:=True;
  end;
end;

procedure Tfrm_Main.lv_ShortcutItemSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var PItem:PShortCutItem;
begin
  FreeAndNil(FCurShortCutPanel);
  PItem:=PShortCutItem(Item.Data);
  if assigned(PItem.onClick) then
    pItem.onClick(self);
end;

procedure Tfrm_Main.lv_ShortcutItemGetImageIndex(Sender: TObject;
  Item: TListItem);
begin
  if Item.Selected then
    Item.ImageIndex:=1
  else Item.ImageIndex:=0;
end;

function Tfrm_Main.FindTab(const tabName: string): TTabSheet;
var i:integer;
    s:String;
begin
  Result:=nil;
  for i:=0 to self.Page_Form.PageCount-1 do
  begin
    s:=self.Page_Form.Pages[i].Name;
    if CompareText(tabName,s)=0 then
    begin
      Result:=self.Page_Form.Pages[i];
      exit;
    end;
  end;
end;

procedure Tfrm_Main.CloseForm(aForm:TForm);
var tab:TTabSheet;
    idx:Integer;
begin
  tab:=self.FindTab(aForm.ClassName);
  if Assigned(tab) then
  begin
    idx:=tab.TabIndex;
    PostMessage(self.Handle,Msg_ClosePage,idx,0);
  end;
end;

procedure Tfrm_Main.N1Click(Sender: TObject);
begin
  CloseActivePage;
end;

procedure Tfrm_Main.CloseActivePage;
var tab:TTabSheet;
begin
  tab:=self.Page_Form.ActivePage;
  if tab.TabIndex<>0 then
    self.CloseForm(TForm(tab.Tag));
end;

procedure Tfrm_Main.Page_FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button=mbLeft) and (ssDouble in Shift) then
    self.CloseActivePage;
end;

procedure Tfrm_Main.ClosePage(var Message: TMessage);
var idx:Integer;
begin
  idx:=Message.WParam;
  self.Page_Form.Pages[idx].Free;
  if idx>0 then
    self.Page_Form.ActivePageIndex:=idx-1;
end;

end.

