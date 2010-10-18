{------------------------------------
  功能说明：展示平台所有服务接口
  创建日期：2010.04.21
  作者：WZW
  版权：WZW
-------------------------------------}
unit ViewSvcInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls,SvcInfoIntf, StdCtrls, ImgList, Menus,
  ToolWin,uBaseForm;

type
  PSvcInfoRec=^TSvcInfoRec;
  
  Tfrm_SvcInfo = class(TBaseForm,ISvcInfoGetter)
    tv_Svc: TTreeView;
    Splitter1: TSplitter;
    Pnl_Svc: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    edt_Title: TEdit;
    edt_GUID: TEdit;
    edt_Ver: TEdit;
    edt_ModuleName: TEdit;
    mm_Comments: TMemo;
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    procedure tv_SvcDeletion(Sender: TObject; Node: TTreeNode);
    procedure FormCreate(Sender: TObject);
    procedure tv_SvcChange(Sender: TObject; Node: TTreeNode);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
  private
    procedure StartEnum;
    function GetNode(const NodeText:String):TTreeNode;
  protected
    {ISvcInfoGetter}
    procedure SvcInfo(SvcInfo:TSvcInfoRec);
  public
    { Public declarations }
  end;

var
  frm_SvcInfo: Tfrm_SvcInfo;

implementation

uses SysSvc;

{$R *.dfm}

{ Tfrm_SvcInfo }

function Tfrm_SvcInfo.GetNode(const NodeText: String): TTreeNode;
var i:Integer;
begin
  Result:=nil;
  for i:=0 to self.tv_Svc.Items.Count-1 do
  begin
    if CompareText(self.tv_Svc.Items[i].Text,NodeText)=0 then
    begin
      Result:=self.tv_Svc.Items[i];
      exit;
    end;
  end;
end;

procedure Tfrm_SvcInfo.StartEnum;
var SvcInfoEx:ISvcInfoEx;
begin
  if SysService.QueryInterface(ISvcInfoEx,SvcInfoEx)=S_OK then
  begin
    self.tv_Svc.Items.BeginUpdate;
    try
      self.tv_Svc.Items.Clear;
      SvcInfoEx.GetSvcInfo(self);
      self.tv_Svc.Items[0].Expanded:=True;
    finally
      self.tv_Svc.Items.EndUpdate;
    end;
  end;
end;

procedure Tfrm_SvcInfo.tv_SvcDeletion(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node.Data) then
    Dispose(PSvcInfoRec(Node.Data));
end;

procedure Tfrm_SvcInfo.FormCreate(Sender: TObject);
begin
  StartEnum;
end;

procedure Tfrm_SvcInfo.tv_SvcChange(Sender: TObject; Node: TTreeNode);
var SvcInfo:PSvcInfoRec;
begin
  self.edt_Title.Text     :='';
  self.edt_GUID.Text      :='';
  self.edt_Ver.Text       :='';
  self.edt_ModuleName.Text:='';
  self.mm_Comments.Text   :='';
  if Assigned(Node.Data) then
  begin
    SvcInfo:=PSvcInfoRec(Node.Data);
    self.edt_Title.Text     :=SvcInfo^.Title;
    self.edt_GUID.Text      :=Node.Text;
    self.edt_Ver.Text       :=SvcInfo^.Version;
    self.edt_ModuleName.Text:=SvcInfo^.ModuleName;
    self.mm_Comments.Text   :=SvcInfo^.Comments;
  end;
end;

procedure Tfrm_SvcInfo.ToolButton2Click(Sender: TObject);
begin
  self.Close;
end;

procedure Tfrm_SvcInfo.ToolButton1Click(Sender: TObject);
var GUID:String;
    i:Integer;
begin
  if InputQuery('查找接口','请输入接口的GUID：',GUID) then
  begin
    for i:=0 to self.tv_Svc.Items.Count-1 do
    begin
      if Pos(GUID,self.tv_Svc.Items[i].Text)<>0 then
      begin
        self.tv_Svc.Items[i].Selected:=True;
        self.tv_Svc.Items[i].Expanded:=true;
        exit;
      end;
    end;
  end;
end;

procedure Tfrm_SvcInfo.SvcInfo(SvcInfo: TSvcInfoRec);
var RNode,PNode,NewNode:TTreeNode;
    SvcInfoRec:PSvcInfoRec;
    ModuleName:String;
begin
  RNode:=self.GetNode('所有接口');
  if RNode=nil then
  begin
    RNode:=self.tv_Svc.Items.AddChild(nil,'所有接口');
    RNode.ImageIndex:=0;
    RNode.SelectedIndex:=0;
  end;
  ModuleName:=SvcInfo.ModuleName;
  if ModuleName='' then ModuleName:='<未知>';
  PNode:=self.GetNode(ModuleName);
  if PNode=nil then
  begin
    PNode:=self.tv_Svc.Items.AddChild(RNode,ModuleName);
    PNode.ImageIndex:=1;
    PNode.SelectedIndex:=1;
  end;
  NewNode:=self.tv_Svc.Items.AddChild(PNode,SvcInfo.GUID);
  NewNode.ImageIndex   :=2;
  NewNode.SelectedIndex:=2;
  New(SvcInfoRec);
  SvcInfoRec^.ModuleName:=ModuleName;
  SvcInfoRec^.Title     :=SvcInfo.Title;
  SvcInfoRec^.Version   :=SvcInfo.Version;
  SvcInfoRec^.Comments  :=SvcInfo.Comments;
  NewNode.Data:=SvcInfoRec;
end;

end.
