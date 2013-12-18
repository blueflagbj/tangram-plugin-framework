{------------------------------------
  功能说明：平台常用功能窗体，要实现IShortCutClick接口
  创建日期：2008/11/19
  作者：wzw
  版权：wzw
-------------------------------------}
unit ShortCutFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Buttons, ImgList, ComCtrls,
  MainFormIntf,uMain;

type
  Tfrm_ShortCut = class(TForm,IShortCutClick)
    lv_ShortcutItem: TListView;
    ImageList1: TImageList;
    Splitter1: TSplitter;
    pnl_ShortCutView: TPanel;
    procedure lv_ShortcutItemGetImageIndex(Sender: TObject; Item: TListItem);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lv_ShortcutItemSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    FCurShortCutPanel:TCustomFrame;
  protected
    {IShortCutClick}
    //注册快捷菜单面板
    procedure RegPanel(FrameClass:TCustomFrameClass);
  public
    procedure RegShotcutItem(PItem:PShortCutItem);
  end;

var
  frm_ShortCut: Tfrm_ShortCut;

implementation

{$R *.dfm}

procedure Tfrm_ShortCut.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //Action:=caFree;
end;

procedure Tfrm_ShortCut.FormCreate(Sender: TObject);
begin
  FCurShortCutPanel:=nil;
end;

procedure Tfrm_ShortCut.lv_ShortcutItemGetImageIndex(Sender: TObject;
  Item: TListItem);
begin
  if Item.Selected then
    Item.ImageIndex:=1
  else Item.ImageIndex:=0;
end;

procedure Tfrm_ShortCut.lv_ShortcutItemSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var PItem:PShortCutItem;
begin
  FreeAndNil(FCurShortCutPanel);
  PItem:=PShortCutItem(Item.Data);
  if assigned(PItem.onClick) then
    pItem.onClick(self);
end;

procedure Tfrm_ShortCut.RegPanel(FrameClass: TCustomFrameClass);
begin
  //FreeAndNil(FCurShortCutPanel);
  if assigned(FrameClass) then
  begin
    FCurShortCutPanel:=FrameClass.Create(nil);
    FCurShortCutPanel.Parent:=pnl_ShortCutView;
    FCurShortCutPanel.Align:=alClient;
    FCurShortCutPanel.Visible:=True;
  end;
end;

procedure Tfrm_ShortCut.RegShotcutItem(PItem: PShortCutItem);
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

end.
