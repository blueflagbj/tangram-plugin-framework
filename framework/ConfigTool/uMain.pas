{------------------------------------
  功能说明：平台配置工具，类似windows的regedit.exe
  创建日期：2008/11/15
  作者：wzw
  版权：wzw
-------------------------------------}
unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, ExtCtrls,RegIntf, StdCtrls, ImgList,StdVcl,AxCtrls,
  IniFiles; 
type
  PNodeInfo=^RNodeInfo;
  RNodeInfo=Record
    Key:String;
  End;
  Tfrm_Main = class(TForm)
    tv_Reg: TTreeView;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    Splitter1: TSplitter;
    statu_Msg: TStatusBar;
    N3: TMenuItem;
    N4: TMenuItem;
    ImgList: TImageList;
    pMenu_Key: TPopupMenu;
    pMenu_Value: TPopupMenu;
    N5: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N6: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    N18: TMenuItem;
    lv_Value: TListView;
    N7: TMenuItem;
    N15: TMenuItem;
    N21: TMenuItem;
    N22: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure tv_RegDeletion(Sender: TObject; Node: TTreeNode);
    procedure tv_RegChange(Sender: TObject; Node: TTreeNode);
    procedure tv_RegMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N5Click(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N8Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N16Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N20Click(Sender: TObject);
    procedure lv_ValueDblClick(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure N22Click(Sender: TObject);
  private
    Reg:IRegistry;
    procedure EumKeyInTree(PTreeNode:TtreeNode;const Key:string);
    procedure EumKeyValue(Node:TtreeNode);
    function GetNodeKey(Node:TtreeNode):string;

    procedure FillPrentKeyToList(Node:TtreeNode;aList:TStrings);
    procedure AddKey(Node:TtreeNode);
    procedure DeleteKey(Node:TtreeNode);

    procedure AddValue(Node:TtreeNode);
    procedure EditValue(CurListItem:TListItem);
    procedure DeleteValue(CurListItem:TListItem);
  public
  end;

var
  frm_Main: Tfrm_Main;

implementation

uses RegObj,editValue,newKey,ModuleMgr,About,MenuEditor,ToolEditor;
{$R *.dfm}

procedure Tfrm_Main.AddKey(node: TtreeNode);
var Key,KeyName:String;
    nodeInfo:PNodeInfo;
    idx:Integer;
    pNode,newNode:TtreeNode;
begin
  frm_newKey:=Tfrm_newKey.Create(nil);
  try
    FillPrentKeyToList(tv_reg.Selected,frm_newKey.cb_ParentKey.Items);
    if assigned(tv_reg.Selected) then
      frm_newKey.cb_ParentKey.ItemIndex:=
      frm_newKey.cb_ParentKey.Items.IndexOf(tv_reg.Selected.text)
    else frm_newKey.cb_ParentKey.ItemIndex:=0;
    if frm_newKey.ShowModal=mrOK then
    begin
      pNode:=nil;
      KeyName:=frm_newKey.edt_KeyName.Text;
      idx:=frm_newKey.cb_ParentKey.ItemIndex;
      if idx=0 then
        Key:=KeyName
      else begin
        pNode:=TtreeNode(frm_newKey.cb_ParentKey.Items.Objects[idx]);
        nodeInfo:=PNodeInfo(pNode.data);
        key:=nodeInfo^.Key+'\'+KeyName;
      end;
      if Reg.OpenKey(key,True) then
      begin//刷新
        newNode:=tv_reg.Items.AddChild(pNode,KeyName);
        newNode.ImageIndex:=0;
        newNode.SelectedIndex:=1;
        new(nodeInfo);
        nodeInfo^.Key:=Key;
        newNode.Data:=nodeInfo;
        newNode.Selected:=True;
      end;
    end;
  finally
    frm_newKey.Free;
  end;
end;

procedure Tfrm_Main.AddValue(Node: TtreeNode);
var key,aName,Value:string;
begin
  if assigned(Node) then
  begin
    frm_editValue:=Tfrm_editValue.Create(nil);
    try
      if frm_editValue.ShowModal=mrOk then
      begin
        aName:=frm_editValue.edt_Name.Text;
        Value:=frm_editValue.edt_Value.Text;
        key:=PNodeInfo(Node.Data)^.Key;
        if Reg.OpenKey(key,False) then
        begin
          try
            Reg.WriteString(aName,Value);
            EumKeyValue(tv_reg.Selected);//刷新
          Except
            on E:Exception do
              showmessageFmt('添加值出错，错误：%s',[E.Message]);
          end;
        end else showmessage('打开节点出错，未知原因！');
      end;
    finally
      frm_editValue.Free;
    end;
  end else showmessage('请先在左边树型选择节点！');
end;

procedure Tfrm_Main.DeleteKey(node: TtreeNode);
var key:string;
begin
  if assigned(node) then
  begin
    if Application.MessageBox('确定删除当前节点吗？','删除节点',1)=1 then
    begin
      key:=PNodeInfo(node.Data)^.Key;
      if Reg.DeleteKey(key) then
      begin//刷新
        node.Delete;
      end else showmessage('删除失败，未知道原因！');
    end;
  end;
end;

procedure Tfrm_Main.DeleteValue(CurListItem:TListItem);
var key,aName:string;
begin
  if assigned(CurListItem) then
  begin
    if application.MessageBox('确定要删除当前值吗？','删除数值',1)=1 then
    begin
      key:=PNodeInfo(CurListItem.Data)^.Key;
      aName:=CurListItem.Caption;
      if Reg.OpenKey(key,False) then
      begin
        if Reg.DeleteValue(aName) then
        begin
          CurListItem.Delete;
        end else showmessage('删除值出错，未知原因！');
      end else showmessage('打开节点时出错，未知原因！');
    end;
  end else showmessage('请选择一个值才能删除！');
end;

procedure Tfrm_Main.EditValue(CurListItem:TListItem);
var key,aName,Value:string;
begin
  if not assigned(CurListItem) then
  begin
    showmessage('请选择一个值才能编辑！');
    exit;
  end;
  frm_editValue:=Tfrm_editValue.Create(nil);
  try
    frm_editValue.edt_Name.Text:=CurListItem.Caption;
    frm_editValue.edt_Name.ReadOnly:=True;
    frm_editValue.edt_Name.Color:=clBtnFace;
    frm_editValue.edt_Value.Text:=CurListItem.SubItems[0];
    if frm_editValue.ShowModal=mrOk then
    begin
      aName:=frm_editValue.edt_Name.Text;
      Value:=frm_editValue.edt_Value.Text;
      key:=PNodeInfo(CurListItem.Data)^.Key;
      if Reg.OpenKey(key,False) then
      begin
        try
          Reg.WriteString(aName,Value);
          EumKeyValue(tv_reg.Selected);//刷新
        Except
          on E:Exception do
            showmessageFmt('编辑值保存时出错，错误：%s',[E.Message]);
        end;
      end else showmessage('打开节点出错，未知原因！');
    end;
  finally
    frm_editValue.Free;
  end;
end;

procedure Tfrm_Main.EumKeyInTree(PTreeNode: TtreeNode; const Key: string);
var aList:TStrings;
    newNode:TtreeNode;
    i:integer;
    NodeInfo:PNodeInfo;
    Curkey:string;
begin
  aList:=TStringList.Create;
  try
    if Reg.OpenKey(Key,False) then
    begin
      Reg.GetKeyNames(aList);
      for i := 0 to aList.Count - 1 do
      begin
        newNode:=tv_reg.Items.AddChild(PTreeNode,aList[i]);
        newNode.ImageIndex:=0;
        newNode.SelectedIndex:=1;
        Curkey:=Key+'\'+aList[i];
        new(NodeInfo);
        NodeInfo^.Key:=Curkey;
        newNode.Data:=NodeInfo;
        EumKeyInTree(newNode,CurKey);
      end;
    end;
  finally
    aList.Free;
  end;
end;

procedure Tfrm_Main.EumKeyValue(Node: TtreeNode);
var key:string;
    aList:TStrings;
    i:integer;
    Value,ValueName:Widestring;
    newItem:TListItem;
begin
  if Node=Nil then Exit;
  lv_Value.Items.BeginUpdate;
  lv_Value.Items.Clear;
  aList:=TStringList.Create;
  try
    key:=GetNodeKey(Node);
    if Reg.OpenKey(Key,False) then
    begin
      Reg.GetValueNames(aList);
      for i := 0 to aList.count - 1 do
      begin
        newItem:=lv_Value.Items.Add;
        ValueName:=aList[i];
        newItem.Caption:=ValueName;
        newItem.ImageIndex:=2;

        Reg.ReadString(ValueName,value);
        newItem.SubItems.Add(value);
        newItem.Data:=node.Data;
      end;
    end;
  finally
    lv_Value.Items.EndUpdate;
    aList.Free;
  end;
end;

procedure Tfrm_Main.FillPrentKeyToList(node: TtreeNode; aList: TStrings);
var pNode,tmpNode:TtreeNode;
    i:integer;
begin
  aList.Clear;
  aList.Add('<无>');
  if assigned(node) then
  begin
    pNode:=node.Parent;
    if assigned(pNode) then
    begin
      for i := 0 to pNode.Count - 1 do
      begin
        tmpNode:=pNode.Item[i];
        aList.AddObject(tmpNode.Text,tmpNode);
      end;
    end else begin
      for i := 0 to tv_reg.Items.count - 1 do
      begin
        tmpNode:=tv_reg.Items[i];
        if tmpNode.Level=0 then
          aList.AddObject(tmpNode.Text,tmpNode);
      end;
    end;
  end;
end;

procedure Tfrm_Main.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Reg.SaveData;
end;

procedure Tfrm_Main.FormCreate(Sender: TObject);
var RegFile,IniFile,AppPath:string;
    ini:TInifile;
begin
  AppPath:=ExtractFilePath(Paramstr(0));
  IniFile:=AppPath+'Root.ini';
  ini:=TiniFile.Create(IniFile);
  try
    RegFile:=AppPath+ini.ReadString('Default','Reg','Tangram.XML');
    Reg:=TRegObj.create;//GetRegObjIntf(self);
    (Reg as ILoadRegistryFile).LoadRegistryFile(RegFile);

    //在treeView列出所有注册表项
    tv_reg.Items.BeginUpdate;
    try
      EumKeyInTree(nil,'');
    finally
      tv_reg.Items.EndUpdate;
    end;
  finally
    ini.Free;
  end;
end;

procedure Tfrm_Main.FormDestroy(Sender: TObject);
begin
  Reg:=Nil;
end;

function Tfrm_Main.GetNodeKey(Node: TtreeNode): string;
var NodeInfo:PNodeINfo;
begin
  if assigned(Node) then
  begin
    NodeInfo:=PNodeInfo(Node.Data);
    Result:=NodeInfo^.Key;
  end;
end;

procedure Tfrm_Main.lv_ValueDblClick(Sender: TObject);
begin
  if assigned(lv_Value.Selected) then
    EditValue(lv_Value.Selected);
end;

procedure Tfrm_Main.N10Click(Sender: TObject);
begin
  EditValue(lv_Value.Selected);
end;

procedure Tfrm_Main.N11Click(Sender: TObject);
begin
  DeleteValue(lv_Value.Selected);
end;

procedure Tfrm_Main.N12Click(Sender: TObject);
begin
  Reg.SaveData;

  tv_reg.Items.BeginUpdate;
  try
    tv_reg.Items.Clear;
    EumKeyInTree(nil,'');
  finally
    tv_reg.Items.EndUpdate;
  end;
end;

procedure Tfrm_Main.N14Click(Sender: TObject);
begin
  AddKey(tv_reg.Selected);
end;

procedure Tfrm_Main.N16Click(Sender: TObject);
begin
  DeleteKey(tv_reg.Selected);
end;

procedure Tfrm_Main.N18Click(Sender: TObject);
begin
  Reg.SaveData;
end;

procedure Tfrm_Main.N20Click(Sender: TObject);
begin
  EumKeyValue(tv_reg.Selected);
end;

procedure Tfrm_Main.N2Click(Sender: TObject);
begin
  Close;
end;

procedure Tfrm_Main.N4Click(Sender: TObject);
begin
  AboutBox:=TAboutBox.Create(nil);
  try
    AboutBox.ShowModal;
  finally
    AboutBox.Free;
  end;
end;

procedure Tfrm_Main.N5Click(Sender: TObject);
begin
  AddKey(tv_reg.Selected);
end;

procedure Tfrm_Main.N8Click(Sender: TObject);
begin
  DeleteKey(tv_reg.Selected);
end;

procedure Tfrm_Main.N9Click(Sender: TObject);
begin
  AddValue(tv_Reg.Selected);
end;

procedure Tfrm_Main.tv_RegChange(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node.Data) then
  begin
    statu_Msg.SimpleText:=GetNodeKey(Node);
    EumKeyValue(Node);
  end;
end;

procedure Tfrm_Main.tv_RegDeletion(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node.Data) then
  begin
    Dispose(PNodeInfo(Node.Data));
    Node.Data:=nil;
  end;
end;

procedure Tfrm_Main.tv_RegMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var p:Tpoint;
    node:TtreeNode;
begin
  if Button=mbRight then
  begin
    GetCursorPos(P);
    //hit:=tv_reg.GetHitTestInfoAt(x,y);
    //if htOnItem in hit then //hit<>(hit-[htOnItem,htOnIcon])
    //begin
    //end;
    node:=tv_reg.GetNodeAt(x,y);

    if assigned(node) then
      node.Selected:=True;
      
    pMenu_Key.Popup(p.X,p.Y);
  end;
end;

procedure Tfrm_Main.N15Click(Sender: TObject);
begin
  frm_ModuleMgr:=Tfrm_ModuleMgr.Create(nil,self.Reg);
  frm_ModuleMgr.ShowModal;
  frm_ModuleMgr.Free;
end;

procedure Tfrm_Main.N21Click(Sender: TObject);
begin
  Frm_MenuEditor:=TFrm_MenuEditor.Create(nil,self.Reg);
  Frm_MenuEditor.ShowModal;
  Frm_MenuEditor.Free;
end;

procedure Tfrm_Main.N22Click(Sender: TObject);
begin
  frm_ToolEditor:=Tfrm_ToolEditor.Create(nil,self.Reg);
  frm_ToolEditor.ShowModal;
  frm_ToolEditor.Free;
end;

initialization

finalization

end.

