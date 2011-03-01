unit MenuEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls,RegIntf;

type
  PNodeData=^TNodeData;
  TNodeData=Record
    Key:String;
  end;
  TFrm_MenuEditor = class(TForm)
    tv_Menu: TTreeView;
    btn_MoveUp: TSpeedButton;
    btn_MoveDown: TSpeedButton;
    btn_OK: TBitBtn;
    btn_Cancel: TBitBtn;
    procedure tv_MenuChange(Sender: TObject; Node: TTreeNode);
    procedure btn_MoveUpClick(Sender: TObject);
    procedure btn_MoveDownClick(Sender: TObject);
    procedure tv_MenuDeletion(Sender: TObject; Node: TTreeNode);
    procedure btn_OKClick(Sender: TObject);
  private
    Reg:IRegistry;
    procedure DisMenu;
    function GetTVNode(PNode:TTreeNode;const NodeText:String):TTreeNode;
    procedure SaveModify;
    function GetPath(Node:TTreeNode):String;
  public
    Constructor Create(AOwner:TComponent;aReg:IRegistry);ReIntroduce;
  end;

var
  Frm_MenuEditor: TFrm_MenuEditor;

implementation

uses StdVcl,AxCtrls;

{$R *.dfm}

const MenuKey='SYSTEM\MENU';

{ TFrm_MenuEditor }

constructor TFrm_MenuEditor.Create(AOwner: TComponent; aReg: IRegistry);
begin
  Inherited Create(AOwner);
  Reg:=aReg;

  self.tv_Menu.Items.BeginUpdate;
  try
    self.tv_Menu.Items.Clear;
    DisMenu;
    if self.tv_Menu.Items.Count>0 then
      self.tv_Menu.Items[0].Expanded:=True;
  finally
    self.tv_Menu.Items.EndUpdate;
  end;
end;

procedure TFrm_MenuEditor.DisMenu;
var i,j:Integer;
    aList,vList:TStrings;
    PNode,aNode:TTreeNode;
    vName,vStr:WideString;
    vAnsiStr,MStr:String;
    NodeData:PNodeData;
begin
  if Reg.OpenKey(MenuKey) then
  begin
    aList:=TStringList.Create;
    vList:=TStringList.Create;
    try
      self.tv_Menu.Items.AddChild(nil,'²Ëµ¥');
      Reg.GetValueNames(aList);
      for i:=0 to aList.Count-1 do
      begin
        PNode:=self.GetTVNode(nil,'²Ëµ¥');
        vName:=aList[i];
        if Reg.ReadString(vName,vStr) then
        begin
          aNode:=nil;
          vAnsiStr:=vStr;
          vList.Clear;
          ExtractStrings(['\'],[],pchar(vAnsiStr),vList);
          for j:=0 to vList.Count-1 do
          begin
            MStr:=vList[j];
            aNode:=self.GetTVNode(PNode,MStr);
            if aNode=nil then
            begin
              aNode:=self.tv_Menu.Items.AddChild(PNode,MStr);
              //..
            end;
            PNode:=aNode;
          end;
          New(NodeData);
          NodeData^.Key:=vName;
          aNode.Data:=NodeData;
        end;
      end;
    finally
      aList.Free;
      vList.Free;
    end;
  end;
end;

function TFrm_MenuEditor.GetTVNode(PNode:TTreeNode;const NodeText: String): TTreeNode;
var i:Integer;
begin
  Result:=Nil;
  if PNode=nil then
    PNode:=self.tv_Menu.TopItem;
  if CompareText(PNode.Text,NodeText)=0 then
  begin
    Result:=PNode;
    exit;
  end;
  for i:=0 to PNode.Count-1 do
  begin
    if CompareText(PNode.Item[i].Text,NodeText)=0 then
    begin
      Result:=PNode.Item[i];
      exit;
    end;
  end;
end;

procedure TFrm_MenuEditor.tv_MenuChange(Sender: TObject; Node: TTreeNode);
begin
  btn_MoveUp.Enabled:=not Node.IsFirstNode;
  btn_MoveDown.Enabled:=not Node.IsFirstNode;
end;

procedure TFrm_MenuEditor.btn_MoveUpClick(Sender: TObject);
var Node:TTreeNode;
begin
  Node:=self.tv_Menu.Selected;
  if Node=nil then exit;
  if Node.getPrevSibling<>nil then
    Node.MoveTo(Node.getPrevSibling,naInsert);
end;

procedure TFrm_MenuEditor.btn_MoveDownClick(Sender: TObject);
var Node:TTreeNode;
begin
  Node:=self.tv_Menu.Selected;
  if Node=nil then exit;
  if Node.getNextSibling<>nil then
    Node.getNextSibling.MoveTo(Node,naInsert);
end;

procedure TFrm_MenuEditor.tv_MenuDeletion(Sender: TObject;
  Node: TTreeNode);
begin
  if Assigned(Node.Data) then
    Dispose(PNodeData(Node.Data));
end;

procedure TFrm_MenuEditor.btn_OKClick(Sender: TObject);
begin
  self.SaveModify;
  self.ModalResult:=mrOk;
end;

procedure TFrm_MenuEditor.SaveModify;
var i:Integer;
    Key,Path:String;
begin
  Reg.DeleteKey(MenuKey);
  if Reg.OpenKey(MenuKey,True) then
  begin
    for i:=0 to self.tv_Menu.Items.Count-1 do
    begin
      if Assigned(self.tv_Menu.Items[i].Data) then
      begin
        Key:=PNodeData(self.tv_Menu.Items[i].Data)^.Key;
        Path:=self.GetPath(self.tv_Menu.Items[i]);
        Reg.WriteString(Key,Path);
      end;
    end;
  end;
end;

function TFrm_MenuEditor.GetPath(Node: TTreeNode): String;
var PNode:TTreeNode;
    Path:string;
begin
  Path:=Node.Text;
  PNode:=Node.Parent;
  while not PNode.IsFirstNode do
  begin
    Path:=PNode.Text+'\'+Path;
    PNode:=PNode.Parent;
  end;
  Result:=Path;
end;

end.
