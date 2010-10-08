unit PackageMgr;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, ExtCtrls, ToolWin,RegIntf, ImgList;

type
  PPackageRec=^TPackageRec;
  TPackageRec=Record
    Key:String;
    Package:string;
    PackageFile:String;
    PackageFileValue:String;
    //Load:Boolean;
    PathInvalid:Boolean;
  end;
  Tfrm_PackageMgr = class(TForm)
    ToolBar1: TToolBar;
    btn_InstallPckage: TToolButton;
    btn_UnInstalll: TToolButton;
    lv_package: TListView;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ImageList1: TImageList;
    btn_Edit: TToolButton;
    OpenDialog1: TOpenDialog;
    procedure ToolButton3Click(Sender: TObject);
    procedure lv_packageDeletion(Sender: TObject; Item: TListItem);
    procedure lv_packageInfoTip(Sender: TObject; Item: TListItem;
      var InfoTip: String);
    procedure lv_packageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btn_EditClick(Sender: TObject);
    procedure lv_packageDblClick(Sender: TObject);
    procedure btn_UnInstalllClick(Sender: TObject);
    procedure btn_InstallPckageClick(Sender: TObject);
  private
    Reg:IRegistry;
    procedure Installpackage(const PckageFile:string);
    procedure UnInstallPackage(const PckageFile:string);
    procedure DisPackageInList(const Key:String);
    procedure UpdateValue(PackageRec:PPackageRec;Load:Boolean);
  public
    Constructor Create(AOwner:TComponent;aReg:IRegistry);ReIntroduce;
  end;

var
  frm_PackageMgr: Tfrm_PackageMgr;

implementation

{$R *.dfm}
Type
  TPro_UnInstallPackage=procedure(Reg:IRegistry);
  TPro_InstallPackage=procedure(Reg:IRegistry);

const
  PackageKey='SYSTEM\LOADPACKAGE';
  Value_Package='PACKAGE';//注册表关键字。。。
  Value_Load='LOAD';//

procedure Tfrm_PackageMgr.Installpackage(const PckageFile: string);
var HHandle:HMODULE;
    Pro_InstallPackage:TPro_InstallPackage;
begin
  HHandle:=SafeLoadLibrary(PckageFile);
  try
    if HHandle<>0 then
    begin
      @Pro_InstallPackage:=GetProcAddress(HHandle,'InstallPackage');
      if Assigned(@Pro_InstallPackage) then
        Pro_InstallPackage(self.Reg)
      else Raise Exception.CreateFmt('[%s]不是系统支持的包！',[PckageFile]);
    end;
  finally
    FreeLibrary(HHandle);
  end;
end;

procedure Tfrm_PackageMgr.UnInstallPackage(const PckageFile: string);
var HHandle:HMODULE;
    Pro_UnInstallPackage:TPro_UnInstallPackage;
begin
  HHandle:=SafeLoadLibrary(PckageFile);
  try
    if HHandle<>0 then
    begin
      @Pro_UnInstallPackage:=GetProcAddress(HHandle,'UnInstallPackage');
      if Assigned(@Pro_UnInstallPackage) then
        Pro_UnInstallPackage(self.Reg)
      else Raise Exception.CreateFmt('[%s]不是系统支持的包！',[PckageFile]);
    end;
  finally
    FreeLibrary(HHandle);
  end;
end;

procedure Tfrm_PackageMgr.ToolButton3Click(Sender: TObject);
begin
  self.Close;
end;

constructor Tfrm_PackageMgr.Create(AOwner: TComponent;
  aReg: IRegistry);
begin
  Inherited Create(AOwner);
  Reg:=aReg;

  self.lv_package.Clear;
  self.DisPackageInList(PackageKey);
end;

function FormatPath(const s:string):string;
const Var_AppPath='($APP_PATH)';
begin
  Result:=StringReplace(s,Var_AppPath,ExtractFilePath(Paramstr(0)),[rfReplaceAll,rfIgnoreCase]);
end;

procedure Tfrm_PackageMgr.DisPackageInList(const Key:String);
var SubKeyList,ValueList,aList:TStrings;
    i:Integer;
    valueStr:string;
    valueName,vStr,PackageFile,Load:WideString;
    NewItem:TListITem;
    PackageRec:PPackageRec;
    PackageFileValue:String;
begin
  SubKeyList:=TStringList.Create;
  ValueList:=TStringList.Create;
  aList:=TStringList.Create;
  try
    if Reg.OpenKey(Key,False) then
    begin
      //处理值
      Reg.GetValueNames(ValueList);
      for i := 0 to ValueList.count - 1 do
      begin
        aList.Clear;
        ValueName:=ValueList[i];
        if Reg.ReadString(ValueName,vStr) then
        begin
          ValueStr:=AnsiUpperCase(vStr);
          ExtractStrings([';'],[],Pchar(valueStr),aList);
          PackageFileValue:=aList.Values[Value_Package];
          PackageFile:=FormatPath(PackageFileValue);
          Load:=aList.Values[Value_Load];

          NewItem:=self.lv_package.Items.Add;
          
          New(PackageRec);
          PackageRec^.Key:=Key;
          PackageRec^.Package:=ValueName;
          //PackageRec^.Load:=CompareText(Load,'TRUE')=0;
          PackageRec^.PackageFile:=PackageFile;
          PackageRec^.PackageFileValue:=PackageFileValue;
          PackageRec^.PathInvalid:=not FileExists(PackageFile);
          NewItem.Data:=PackageRec;

          NewItem.SubItems.Add(ValueName);
          NewItem.SubItems.Add(PackageFileValue);
          NewItem.Checked:=CompareText(Load,'TRUE')=0;
          if PackageRec^.PathInvalid then
            NewItem.ImageIndex:=4
          else NewItem.ImageIndex:=3;
        end;
      end;
    end;
    //向下查找
    Reg.GetKeyNames(SubKeyList);
    for i := 0 to SubKeyList.Count - 1 do
      DisPackageInList(Key+'\'+SubKeyList[i]);//递归
  finally
    SubKeyList.Free;
    ValueList.Free;
    aList.Free;
  end;
end;

procedure Tfrm_PackageMgr.lv_packageDeletion(Sender: TObject;
  Item: TListItem);
begin
  if Assigned(Item.Data) then
    Dispose(PPackageRec(Item.Data));
end;

procedure Tfrm_PackageMgr.lv_packageInfoTip(Sender: TObject;
  Item: TListItem; var InfoTip: String);
begin
  if Assigned(Item.Data) then
  begin
    if PPackageRec(Item.Data)^.PathInvalid then
      InfoTip:=Format('包[%s]路径不正确，请重新安装！',[PPackageRec(Item.Data)^.Package]);
  end;
end;

procedure Tfrm_PackageMgr.lv_packageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var HitTest:THitTests;
    Item:TListItem;
begin
  HitTest:=self.lv_package.GetHitTestInfoAt(X,Y);
  if (htOnStateIcon in HitTest) then
  begin
    Item:=self.lv_package.GetItemAt(X,Y);
    if Item<>nil then
    begin
      if Assigned(Item.Data) then
        self.UpdateValue(PPackageRec(Item.Data),Item.Checked);
    end;
  end;
end;

procedure Tfrm_PackageMgr.UpdateValue(PackageRec:PPackageRec;Load: Boolean);
const V_Str='Package=%s;Load=%s';
var Value,LoadStr:String;
begin
  if Reg.OpenKey(PackageRec^.Key) then
  begin
    if Load then
      LoadStr:='True'
    else LoadStr:='False';
    Value:=Format(V_Str,[PackageRec^.PackageFileValue,LoadStr]);
    Reg.WriteString(PackageRec^.Package,Value);
  end;
end;

procedure Tfrm_PackageMgr.btn_EditClick(Sender: TObject);
var Path:String;
    PackageRec:PPackageRec;
begin
  if Assigned(self.lv_package.Selected) then
  begin
    if Assigned(self.lv_package.Selected.Data) then
    begin
      PackageRec:=PPackageRec(self.lv_package.Selected.Data);
      Path:=PackageRec^.PackageFileValue;
      if InputQuery('编辑','编辑包路径:'+#13#10+'($APP_PATH)=程序所在目录',Path) then
      begin
        PackageRec^.PackageFileValue:=Path;
        PackageRec^.PackageFile:=FormatPath(Path);
        self.UpdateValue(PackageRec,self.lv_package.Selected.Checked);
        self.lv_package.Selected.SubItems[1]:=Path;
        if FileExists(PackageRec^.PackageFile) then
          self.lv_package.Selected.ImageIndex:=3
        else self.lv_package.Selected.ImageIndex:=4;
      end;
    end;
  end;
end;

procedure Tfrm_PackageMgr.lv_packageDblClick(Sender: TObject);
begin
  self.btn_Edit.Click;
end;

procedure Tfrm_PackageMgr.btn_UnInstalllClick(Sender: TObject);
var PackageRec:PPackageRec;
begin
  if Assigned(self.lv_package.Selected) then
  begin
    if Assigned(self.lv_package.Selected.Data) then
    begin
      PackageRec:=PPackageRec(self.lv_package.Selected.Data);
      if FileExists(PackageRec^.PackageFile) then
      begin
        if MessageBox(self.Handle,pchar('你确定要卸载['+PackageRec^.Package+']包吗？')
          ,'卸载包',MB_YESNO+MB_ICONQUESTION)<>IDYES then exit;
        Try
          self.UnInstallPackage(PackageRec^.PackageFile);
          self.lv_package.Selected.Delete;
        Except
          on E:Exception do
            MessageBox(self.Handle,pchar('卸载出错：'+E.Message),'卸载包',MB_OK+MB_ICONERROR);
        end;
      end else begin
        if MessageBox(self.Handle,pchar('包['+PackageRec^.Package
          +']路径不正确，无法卸载，是否直接从注册表删除该包信息？'),'卸载包',MB_YESNO+MB_ICONQUESTION)=IDYES then
        begin
          if Reg.OpenKey(PackageRec^.Key) then
          begin
            Reg.DeleteValue(PackageRec^.Package);
            self.lv_package.Selected.Delete;
          end;
        end;
      end;
    end;
  end;
end;

procedure Tfrm_PackageMgr.btn_InstallPckageClick(Sender: TObject);
var i:Integer;
    FileName:string;
begin
  if self.OpenDialog1.Execute then
  begin
    for i:=0 to self.OpenDialog1.Files.Count-1 do
    begin
      try
        FileName:=self.OpenDialog1.Files[i];
        self.Installpackage(FileName);
        //刷新
        self.lv_package.Clear;
        self.DisPackageInList(PackageKey);
      except
        on E:Exception do
          MessageBox(self.Handle,pchar('安装包失败：'+E.Message),'安装新包',MB_OK+MB_ICONERROR);
      end;
    end;
  end;
end;

end.
