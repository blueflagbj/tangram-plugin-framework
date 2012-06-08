unit ToolEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls,RegIntf;

type
  PNodeData=^TNodeData;
  TNodeData=Record
    Key:String;
    Caption:String;
    Hint:string;
  end;
  Tfrm_ToolEditor = class(TForm)
    tv_Tool: TTreeView;
    btn_MoveUp: TSpeedButton;
    btn_MoveDown: TSpeedButton;
    btn_Cancel: TBitBtn;
    btn_OK: TBitBtn;
    procedure tv_ToolDeletion(Sender: TObject; Node: TTreeNode);
    procedure tv_ToolChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure btn_MoveUpClick(Sender: TObject);
    procedure btn_MoveDownClick(Sender: TObject);
    procedure btn_OKClick(Sender: TObject);
  private
    Reg:IRegistry;
    procedure DisTool;
    procedure SaveModify;
  public
    constructor Create(AOwner:TComponent;aReg:IRegistry);ReIntroduce;
  end;

var
  frm_ToolEditor: Tfrm_ToolEditor;

implementation

uses StdVcl,AxCtrls;

{$R *.dfm}

const ToolKey='SYSTEM\TOOL';

{ Tfrm_ToolEditor }

constructor Tfrm_ToolEditor.Create(AOwner: TComponent; aReg: IRegistry);
begin
  Inherited Create(AOwner);
  Reg:=aReg;

  self.tv_Tool.Items.BeginUpdate;
  try
    self.tv_Tool.Items.Clear;
    self.DisTool;
    self.tv_Tool.FullExpand;
  finally
    self.tv_Tool.Items.EndUpdate;
  end;
end;

procedure Tfrm_ToolEditor.DisTool;
var aList,vList:TStrings;
    i:Integer;
    vName,aStr:string;
    vStr:WideString;
    PNode,NewNode:TTreeNode;
    NodeData:PNodeData;
begin
  if Reg.OpenKey(ToolKey) then
  begin
    PNode:=self.tv_Tool.Items.AddChild(nil,'¹¤¾ßÀ¸');
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
          NewNode:=self.tv_Tool.Items.AddChild(PNode,vList.Values['Caption']); 
          New(NodeData);
          NodeData^.Key:=vName;
          NodeData^.Caption:=vList.Values['Caption'];
          NodeData^.Hint:=vList.Values['Hint'];
          NewNode.Data:=NodeData;
        end;
      end;
    finally
      aList.Free;
      vList.Free;
    end;
  end;
end;

procedure Tfrm_ToolEditor.tv_ToolDeletion(Sender: TObject;
  Node: TTreeNode);
begin
  if Assigned(Node.Data) then
    Dispose(PNodeData(Node.Data));
end;

procedure Tfrm_ToolEditor.tv_ToolChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
  btn_MoveUp.Enabled:=not Node.IsFirstNode;
  btn_MoveDown.Enabled:=not Node.IsFirstNode;
end;

procedure Tfrm_ToolEditor.btn_MoveUpClick(Sender: TObject);
var Node:TTreeNode;
begin
  Node:=self.tv_Tool.Selected;
  if Node=nil then exit;
  if Node.getPrevSibling<>nil then
    Node.MoveTo(Node.getPrevSibling,naInsert);
end;

procedure Tfrm_ToolEditor.btn_MoveDownClick(Sender: TObject);
var Node:TTreeNode;
begin
  Node:=self.tv_Tool.Selected;
  if Node=nil then exit;
  if Node.getNextSibling<>nil then
    Node.getNextSibling.MoveTo(Node,naInsert);
end;

procedure Tfrm_ToolEditor.SaveModify;
var i:Integer;
    Key,S:String;
    NodeData:PNodeData;
begin
  Reg.DeleteKey(ToolKey);
  if Reg.OpenKey(ToolKey,True) then
  begin
    for i:=0 to self.tv_Tool.Items.Count-1 do
    begin
      if Assigned(self.tv_Tool.Items[i].Data) then
      begin
        NodeData:=PNodeData(self.tv_Tool.Items[i].Data);
        Key:=NodeData^.Key;
        S:=Format('Caption=%s,Hint=%s',[NodeData^.Caption,NodeData^.Hint]);
        Reg.WriteString(Key,S);
      end;
    end;
  end;
end;

procedure Tfrm_ToolEditor.btn_OKClick(Sender: TObject);
begin
  self.SaveModify;
  self.ModalResult:=mrOK;
end;

end.
