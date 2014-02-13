{------------------------------------
  功能说明：权限管理
  创建日期：2010/05/22
  作者：wzw
  版权：wzw
-------------------------------------}
unit uRoleMgr;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseForm, ComCtrls, ImgList, ExtCtrls, ToolWin,DBClient,SysSvc,DB,
  DBIntf,AuthoritySvrIntf;

type
  PNodeData=^TNodeData;
  TNodeData=Record
    State:Integer;//0:不选 1:不确定 2:选择

    aDefault:Boolean;
    Key:String;
  end;

  TFrmRoleMgr = class(TBaseForm)
    ToolBar1: TToolBar;
    Panel1: TPanel;
    lv_Role: TListView;
    Panel2: TPanel;
    tv_Authority: TTreeView;
    imgList: TImageList;
    btn_UpdateRole: TToolButton;
    btn_NewRole: TToolButton;
    Btn_EdtRole: TToolButton;
    Splitter1: TSplitter;
    ImgRole: TImageList;
    cds_Authority: TClientDataSet;
    ToolButton4: TToolButton;
    btn_delRole: TToolButton;
    btn_Save: TToolButton;
    ToolButton7: TToolButton;
    cds_Role: TClientDataSet;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tv_AuthorityGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure tv_AuthorityGetSelectedIndex(Sender: TObject;
      Node: TTreeNode);
    procedure tv_AuthorityMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tv_AuthorityDeletion(Sender: TObject; Node: TTreeNode);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lv_RoleDeletion(Sender: TObject; Item: TListItem);
    procedure lv_RoleSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btn_UpdateRoleClick(Sender: TObject);
    procedure lv_RoleInfoTip(Sender: TObject; Item: TListItem;
      var InfoTip: String);
    procedure btn_NewRoleClick(Sender: TObject);
    procedure lv_RoleDblClick(Sender: TObject);
    procedure btn_delRoleClick(Sender: TObject);
    procedure Btn_EdtRoleClick(Sender: TObject);
    procedure btn_SaveClick(Sender: TObject);
  private
    DBAC:IDBAccess;
    FCurRoleID:Integer;
    FModified:Boolean;

    procedure UpdateParentState(PNode: TTreeNode);
    procedure SetChildState(Node: TTreeNode;State:Integer);

    procedure InitTv;
    function GetTVNode(const NodeText:String):TTreeNode;

    procedure LoadRoles;
    procedure DisRoleInLv;
    procedure LoadAuthority(const RoleID:Integer);

    procedure CheckToSave;
    procedure Save;
  protected
    Class procedure RegAuthority(aIntf:IAuthorityRegistrar);override;
    procedure HandleAuthority(const Key:String;aEnable:Boolean);override;
  public
    { Public declarations }
  end;

var
  FrmRoleMgr: TFrmRoleMgr;

implementation

uses uEdtRole,_Sys;

{$R *.dfm}

procedure TFrmRoleMgr.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  CheckToSave;
  Action:=caFree;
end;

procedure TFrmRoleMgr.SetChildState(Node: TTreeNode;State:Integer);
var i:Integer;
begin
  for i:=0 to Node.Count-1 do
  begin
    if Assigned(Node.Item[i].Data) then
      PNodeData(Node.Item[i].Data)^.State:=State;
    if Node.HasChildren then
      SetChildState(Node.Item[i],State);
  end;
end;

procedure TFrmRoleMgr.UpdateParentState(PNode: TTreeNode);
var i:Integer;
    NodeData:PNodeData;
    State:Integer;
begin
  if not Assigned(PNode) then exit;
  State:=-1;
  for i:=0 to PNode.Count-1 do
  begin
    if Assigned(PNode.Item[i].Data) then
    begin
      NodeData:=PNodeData(PNode.Item[i].Data);
      if State=-1 then
        State:=NodeData^.State
      else begin
        if State<>NodeData^.State then
        begin
          State:=1;
          Break;
        end;
      end;
    end;
  end;
  if Assigned(PNode.Data) then
    PNodeData(PNode.Data)^.State:=State;

  UpdateParentState(PNode.Parent);
end;

procedure TFrmRoleMgr.tv_AuthorityGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  if Assigned(Node.Data) then
    Node.ImageIndex:=PNodeData(Node.Data)^.State;
end;

procedure TFrmRoleMgr.tv_AuthorityGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
  inherited;
  Node.SelectedIndex:=Node.ImageIndex;
end;

procedure TFrmRoleMgr.tv_AuthorityMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var ht:THitTests;
    Node:TTreeNode;
    NodeData:PNodeData;
begin
  if not Assigned(lv_Role.Selected) then exit;

  ht:=self.tv_Authority.GetHitTestInfoAt(x,y);
  Node:=self.tv_Authority.GetNodeAt(x,y);
  if htOnIcon in ht then
  begin
    if Assigned(Node) then
    begin
      if Assigned(Node.Data) then
      begin
        NodeData:=PNodeData(Node.Data);
        Case NodeData^.State of
          0:NodeData^.State:=2;
          1,2:NodeData^.State:=0;
        end;
        self.SetChildState(Node,NodeData^.State);
        self.UpdateParentState(Node.Parent);
        FModified:=True;
      end;
    end;
  end;
  self.tv_Authority.Refresh;
end;

procedure TFrmRoleMgr.tv_AuthorityDeletion(Sender: TObject;
  Node: TTreeNode);
begin
  if Assigned(Node.Data) then
    DisPose(PNodeData(Node.Data));
end;

procedure TFrmRoleMgr.InitTv;
const Sql='Select * from [AuthorityItem]';
var tmpCds:TClientDataSet;
    RootNode,PNode,NewNode:TTreeNode;
    aList:TStrings;
    i:Integer;
    NodeData:PNodeData;
begin
  tmpCds:=TClientDataSet.Create(nil);
  aList:=TStringList.Create;
  self.tv_Authority.Items.BeginUpdate;
  try
    self.tv_Authority.Items.Clear;

    RootNode:=self.tv_Authority.Items.AddChildFirst(nil,'所有权限');
    New(NodeData);
    NodeData^.State:=0;
    NodeData^.Key:='';
    RootNode.Data:=NodeData;
    
    DBAC.QuerySQL(tmpCds,Sql);
    tmpCds.First;
    while not tmpCds.Eof do
    begin
      aList.Delimiter:='\';
      aList.DelimitedText:=tmpCds.fieldbyname('aPath').AsString;
      PNode:=RootNode;
      for i:=0 to aList.Count-1 do
      begin
        NewNode:=self.GetTVNode(aList[i]);
        if NewNode=nil then
        begin
          NewNode:=self.tv_Authority.Items.AddChild(PNode,aList[i]);
          New(NodeData);
          NodeData^.State:=0;
          NodeData^.Key:='';
          NewNode.Data:=NodeData;
        end;
        PNode:=NewNode;
      end;
      NewNode:=self.tv_Authority.Items.AddChild(PNode,tmpCds.fieldbyname('aItemName').AsString);
      New(NodeData);
      NodeData^.State:=0;
      NodeData^.Key:=tmpCds.fieldbyname('aKey').AsString;
      NodeData^.aDefault:=tmpCds.fieldbyname('aDefault').AsBoolean;
      NewNode.Data:=NodeData;
      
      tmpCds.Next;
    end;
    self.tv_Authority.FullExpand;
  finally
    tmpCds.Free;
    aList.Free;
    self.tv_Authority.Items.EndUpdate;
  end;
end;

function TFrmRoleMgr.GetTVNode(const NodeText: String): TTreeNode;
var i:integer;
begin
  Result:=nil;
  for i:=0 to self.tv_Authority.Items.Count-1 do
  begin
    if CompareText(self.tv_Authority.Items[i].Text,NodeText)=0 then
    begin
      Result:=self.tv_Authority.Items[i];
      exit;
    end;
  end;
end;

procedure TFrmRoleMgr.FormShow(Sender: TObject);
begin
  inherited;
  self.LoadRoles;
  self.InitTv;
  self.DisRoleInLv;
end;

procedure TFrmRoleMgr.FormCreate(Sender: TObject);
begin
  inherited;
  FModified:=False;
  DBAC:=SysService as IDBAccess;
end;

procedure TFrmRoleMgr.LoadRoles;
const Sql='Select * from [Role]';
begin
  DBAC.QuerySQL(Cds_Role,Sql);
end;

procedure TFrmRoleMgr.lv_RoleDeletion(Sender: TObject; Item: TListItem);
begin
  inherited;
  if Assigned(Item.Data) then
    IDataRecord(Item.Data)._Release;
end;

procedure TFrmRoleMgr.LoadAuthority(const RoleID: Integer);
const Sql='select * from [RoleAuthority] where RoleID=%d';
var i:Integer;
    NodeData:PNodeData;
begin
  CheckToSave;
  FCurRoleID:=RoleID;

  DBAC.QuerySQL(cds_Authority,Format(Sql,[RoleID]));
  self.tv_Authority.Items.BeginUpdate;
  try
    for i:=0 to self.tv_Authority.Items.Count-1 do
    begin
      if Assigned(self.tv_Authority.Items[i].Data) then
      begin
        NodeData:=PNodeData(self.tv_Authority.Items[i].Data);
        if NodeData^.Key<>'' then
        begin
          if cds_Authority.Locate('aKey',NodeData^.Key,[]) then
          begin
            if cds_Authority.FieldByName('aEnable').AsBoolean then
              NodeData^.State:=2
            else NodeData^.State:=0;
          end else begin
            if NodeData^.aDefault then
              NodeData^.State:=2
            else NodeData^.State:=0;
          end;
          self.UpdateParentState(self.tv_Authority.Items[i].Parent);
        end;
      end;
    end;
    self.FModified:=False;
  finally
    self.tv_Authority.Items.EndUpdate;
  end;
end;

procedure TFrmRoleMgr.lv_RoleSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected then
  begin
    if Assigned(Item.Data) then
     self.LoadAuthority(IDataRecord(Item.Data).FieldValueAsInteger('ID'));
  end;
end;

procedure TFrmRoleMgr.btn_UpdateRoleClick(Sender: TObject);
begin
  inherited;
  (SysService as IAuthoritySvr).UpdateAuthority;
  self.InitTv;
  
  if Assigned(self.lv_Role.Selected) then
     self.LoadAuthority(IDataRecord(self.lv_Role.Selected.Data).FieldValueAsInteger('ID'));
end;

procedure TFrmRoleMgr.lv_RoleInfoTip(Sender: TObject; Item: TListItem;
  var InfoTip: String);
begin
  if Assigned(Item.Data) then
    InfoTip:=IDataRecord(Item.Data).FieldValueAsString('Description');
end;

procedure TFrmRoleMgr.btn_NewRoleClick(Sender: TObject);
begin
  inherited;
  FrmEdtRole:=TFrmEdtRole.Create(nil,nil);
  try
    FrmEdtRole.Caption:='新增角色';
    if FrmEdtRole.ShowModal=mrOK then
    begin
      FrmEdtRole.ResultData.SaveToDataSet('ID',Cds_Role);
      DBAC.BeginTrans;
      try
        DBAC.ApplyUpdate('[Role]',Cds_Role);
        DBAC.CommitTrans;
        
        self.LoadRoles;//新增要重新加载一下，不然没有ID，因为ID是自增的。。。
        self.DisRoleInLv;
      Except
        on E:Exception do
          sys.Dialogs.ShowError(E);
      end;
    end;
  finally
    FrmEdtRole.Free;
  end;
end;

procedure TFrmRoleMgr.lv_RoleDblClick(Sender: TObject);
begin
  inherited;
  Btn_EdtRole.Click;
end;

procedure TFrmRoleMgr.btn_delRoleClick(Sender: TObject);
const DelRoleAuthoritySql='Delete From RoleAuthority where RoleID=%d';
var Rec:IDataRecord;
    RoleID:Integer;
begin
  if Assigned(self.lv_Role.Selected) then
  begin
    Rec:=IDataRecord(self.lv_Role.Selected.Data);
    if sys.Dialogs.Confirm('删除角色','您确定要删除当前选中的角色吗？'+#13#10
      +'注意：删除角色后，该角色下的所有用户将丢失所有权限！') then
    begin
      RoleID:=Rec.FieldValueAsInteger('ID');
      if Cds_Role.Locate('ID',RoleID,[]) then
      begin
        Cds_Role.Delete;

        DBAC.BeginTrans;
        try
          DBAC.ApplyUpdate('[Role]',Cds_Role);

          DBAC.ExecuteSQL(Format(DelRoleAuthoritySql,[RoleID]));
          DBAC.CommitTrans;

          self.lv_Role.Selected.Delete;
        Except
          on E:Exception do
            sys.Dialogs.ShowError(E);
        end;
      end;
    end;
  end else sys.Dialogs.ShowInfo('请先选择一个角色！');
end;

procedure TFrmRoleMgr.Btn_EdtRoleClick(Sender: TObject);
var Rec:IDataRecord;
begin
  if Assigned(self.lv_Role.Selected) then
  begin
    Rec:=IDataRecord(self.lv_Role.Selected.Data);
    FrmEdtRole:=TFrmEdtRole.Create(nil,Rec);
    try
      FrmEdtRole.Caption:='新增角色';
      if FrmEdtRole.ShowModal=mrOK then
      begin
        FrmEdtRole.ResultData.SaveToDataSet('ID',Cds_Role);
        DBAC.BeginTrans;
        try
          DBAC.ApplyUpdate('[Role]',Cds_Role);
          DBAC.CommitTrans;

          self.DisRoleInLv;
        Except
          on E:Exception do
            sys.Dialogs.ShowError(E);
        end;
      end;
    finally
      FrmEdtRole.Free;
    end;
  end else sys.Dialogs.ShowInfo('请先选择一个角色！');
end;

procedure TFrmRoleMgr.DisRoleInLv;
var NewItem:TListItem;
    Rec:IDataRecord;
begin
  self.lv_Role.Items.BeginUpdate;
  try
    self.lv_Role.Clear;
    Cds_Role.First;
    while not Cds_Role.Eof do
    begin
      NewItem:=self.lv_Role.Items.Add;
      NewItem.Caption:=Cds_Role.fieldbyname('RoleName').AsString;
      NewItem.ImageIndex:=0;

      Rec:=SysService as IDataRecord;
      Rec.LoadFromDataSet(Cds_Role);
      Rec._AddRef;
      NewItem.Data:=Pointer(Rec);

      Cds_Role.Next;
    end;
  finally
    self.lv_Role.Items.EndUpdate;
  end;
end;

procedure TFrmRoleMgr.Save;
const Sql='select * from [RoleAuthority] where RoleID=%d';
var i:Integer;
    NodeData:PNodeData;
    tmpCds:TClientDataSet;
begin
  if not self.FModified then exit;
  tmpCds:=TClientDataSet.Create(nil);
  try
    DBAC.QuerySQL(tmpCds,Format(Sql,[self.FCurRoleID]));
    for i:=0 to self.tv_Authority.Items.Count-1 do
    begin
      if Assigned(self.tv_Authority.Items[i].Data) then
      begin
        NodeData:=PNodeData(self.tv_Authority.Items[i].Data);
        if NodeData^.Key<>'' then
        begin
          if tmpCds.Locate('aKey',NodeData^.Key,[]) then
            tmpCds.Edit
          else tmpCds.Append;
          tmpCds.FieldByName('RoleID').AsInteger:=self.FCurRoleID;
          tmpCds.FieldByName('aKey').AsString:=NodeData^.Key;
          tmpCds.FieldByName('aEnable').AsBoolean:=NodeData^.State=2;
          tmpCds.Post;
        end;
      end;
    end;

    DBAC.BeginTrans;
    try
      DBAC.ApplyUpdate('[RoleAuthority]',tmpCds);
      DBAC.CommitTrans;
      Sys.Dialogs.ShowInfo('保存成功！');
    Except
      on E:Exception do
      begin
        DBAC.RollbackTrans;
        Sys.Dialogs.ShowError(E);
      end;
    end;
    FModified:=False;
  finally
    tmpCds.Free;
  end;
end;

procedure TFrmRoleMgr.CheckToSave;
begin
  if self.FModified then
  begin
    if Sys.Dialogs.Ask('角色管理','权限已经改变，是否保存？') then
      self.Save;
  end;
end;

procedure TFrmRoleMgr.btn_SaveClick(Sender: TObject);
begin
  inherited;
  self.Save;
end;

Const Key1='{B928DA74-D9D0-4616-B91B-D2DE65B0DB58}';

class procedure TFrmRoleMgr.RegAuthority(aIntf: IAuthorityRegistrar);
begin
  aIntf.RegAuthorityItem(Key1,'系统管理\权限','角色管理',True);
end;

procedure TFrmRoleMgr.HandleAuthority(const Key: String; aEnable: Boolean);
begin
  if Key=Key1 then
  begin
    if not aEnable then Raise Exception.Create('对不起，你没有权限！');
  end;
end;

end.
