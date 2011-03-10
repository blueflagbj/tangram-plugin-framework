unit ModuleMgr;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, ExtCtrls, ToolWin,RegIntf, ImgList;

type
  TModuleType=(mtUnKnow,mtBPL,mtDLL);

  PModuleRec=^TModuleRec;
  TModuleRec=Record
    Key:String;
    Module:string;
    ModuleFile:String;
    ModuleFileValue:String;
    PathInvalid:Boolean;
    ModuleType:TModuleType;
  end;

  Tfrm_ModuleMgr = class(TForm)
    ToolBar1: TToolBar;
    btn_InstallModule: TToolButton;
    btn_UnInstalll: TToolButton;
    lv_Module: TListView;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ImageList1: TImageList;
    btn_Edit: TToolButton;
    OpenDialog1: TOpenDialog;
    procedure ToolButton3Click(Sender: TObject);
    procedure lv_ModuleDeletion(Sender: TObject; Item: TListItem);
    procedure lv_ModuleInfoTip(Sender: TObject; Item: TListItem;
      var InfoTip: String);
    procedure lv_ModuleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btn_EditClick(Sender: TObject);
    procedure lv_ModuleDblClick(Sender: TObject);
    procedure btn_UnInstalllClick(Sender: TObject);
    procedure btn_InstallModuleClick(Sender: TObject);
  private
    Reg:IRegistry;
    procedure InstallModule(const ModuleFile:string);
    procedure UnInstallModule(const ModuleFile:string);
    procedure DisModuleInList(const Key:String);
    procedure UpdateValue(mRec:PModuleRec;Load:Boolean);

    function ModuleType(const ModuleFile:String):TModuleType;
  public
    Constructor Create(AOwner:TComponent;aReg:IRegistry);ReIntroduce;
  end;

var
  frm_ModuleMgr: Tfrm_ModuleMgr;

implementation
//uses SysModule;
{$R *.dfm}
Type
  TPro_UnInstallModule=procedure(Reg:IRegistry);
  TPro_InstallModule=procedure(Reg:IRegistry);
  //TPro_GetModuleClass=function :TModuleClass;
const
  ModuleKey='SYSTEM\LOADMODULE';
  Value_Module='Module';//注册表关键字。。。
  Value_Load='load';//

procedure Tfrm_ModuleMgr.InstallModule(const ModuleFile: string);
var HHandle:HMODULE;
    Pro_InstallModule:TPro_InstallModule;
    mType:TModuleType;
begin
  mType:=self.ModuleType(ModuleFile);
  case mType of
    mtBpl:HHandle:=LoadPackage(ModuleFile);//SafeLoadLibrary
    mtDLL:HHandle:=LoadLibrary(pchar(ModuleFile));
    else raise Exception.Create('不能识别的模块类型！');
  end;
  if HHandle<>0 then
  begin
    try
      @Pro_InstallModule:=GetProcAddress(HHandle,'InstallModule');
      if Assigned(@Pro_InstallModule) then
        Pro_InstallModule(self.Reg)
      else Raise Exception.CreateFmt('[%s]不是系统支持的模块！',[ModuleFile]);
    finally
      case mType of
        mtBpl:UnLoadPackage(HHandle); //FreeLibrary(HHandle);
        mtDLL:FreeLibrary(HHandle);
      end;
    end;
  end;
end;

procedure Tfrm_ModuleMgr.UnInstallModule(const ModuleFile: string);
var HHandle:HMODULE;
    Pro_UnInstallModule:TPro_UnInstallModule;
    mType:TModuleType;
begin
  mType:=self.ModuleType(ModuleFile);
  case mType of
    mtBpl:HHandle:=LoadPackage(ModuleFile);//SafeLoadLibrary
    mtDLL:HHandle:=LoadLibrary(pchar(ModuleFile));
    else raise Exception.Create('不能识别的模块类型！');
  end;
  if HHandle<>0 then
  begin
    try
      @Pro_UnInstallModule:=GetProcAddress(HHandle,'UnInstallModule');
      if Assigned(@Pro_UnInstallModule) then
        Pro_UnInstallModule(self.Reg)
      else Raise Exception.CreateFmt('[%s]不是系统支持的模块！',[ModuleFile]);
    finally
      case mType of
        mtBpl:UnLoadPackage(HHandle); //FreeLibrary(HHandle);
        mtDLL:FreeLibrary(HHandle);
      end;
    end;
  end;
end;

procedure Tfrm_ModuleMgr.ToolButton3Click(Sender: TObject);
begin
  self.Close;
end;

constructor Tfrm_ModuleMgr.Create(AOwner: TComponent;
  aReg: IRegistry);
begin
  Inherited Create(AOwner);
  Reg:=aReg;

  self.lv_module.Clear;
  self.DisModuleInList(ModuleKey);
end;

function FormatPath(const s:string):string;
const Var_AppPath='($APP_PATH)';
begin
  Result:=StringReplace(s,Var_AppPath,ExtractFilePath(Paramstr(0)),[rfReplaceAll,rfIgnoreCase]);
end;

procedure Tfrm_ModuleMgr.DisModuleInList(const Key:String);
var SubKeyList,ValueList,aList:TStrings;
    i:Integer;
    valueStr:string;
    valueName,vStr,ModuleFile,Load:WideString;
    NewItem:TListITem;
    mRec:PModuleRec;
    ModuleFileValue:String;
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
          ModuleFileValue:=aList.Values[Value_Module];
          ModuleFile:=FormatPath(ModuleFileValue);
          Load:=aList.Values[Value_Load];

          NewItem:=self.lv_module.Items.Add;
          
          New(mRec);
          mRec^.Key            :=Key;
          mRec^.Module         :=ValueName;
          mRec^.ModuleFile     :=ModuleFile;
          mRec^.ModuleFileValue:=ModuleFileValue;
          mRec^.PathInvalid    :=not FileExists(ModuleFile);
          mRec^.ModuleType     :=self.ModuleType(ModuleFile);
          NewItem.Data:=mRec;

          NewItem.SubItems.Add(ValueName);
          NewItem.SubItems.Add(ModuleFileValue);
          NewItem.Checked:=CompareText(Load,'TRUE')=0;
          if mRec^.PathInvalid then
            NewItem.ImageIndex:=4
          else NewItem.ImageIndex:=3;
        end;
      end;
    end;
    //向下查找
    Reg.GetKeyNames(SubKeyList);
    for i := 0 to SubKeyList.Count - 1 do
      DisModuleInList(Key+'\'+SubKeyList[i]);//递归
  finally
    SubKeyList.Free;
    ValueList.Free;
    aList.Free;
  end;
end;

procedure Tfrm_ModuleMgr.lv_ModuleDeletion(Sender: TObject;
  Item: TListItem);
begin
  if Assigned(Item.Data) then
    Dispose(PModuleRec(Item.Data));
end;

procedure Tfrm_ModuleMgr.lv_ModuleInfoTip(Sender: TObject;
  Item: TListItem; var InfoTip: String);
begin
  if Assigned(Item.Data) then
  begin
    if PModuleRec(Item.Data)^.PathInvalid then
      InfoTip:=Format('模块[%s]路径不正确，请重新安装！',[PModuleRec(Item.Data)^.Module]);
  end;
end;

procedure Tfrm_ModuleMgr.lv_ModuleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var HitTest:THitTests;
    Item:TListItem;
begin
  HitTest:=self.lv_module.GetHitTestInfoAt(X,Y);
  if (htOnStateIcon in HitTest) then
  begin
    Item:=self.lv_module.GetItemAt(X,Y);
    if Item<>nil then
    begin
      if Assigned(Item.Data) then
        self.UpdateValue(PModuleRec(Item.Data),Item.Checked);
    end;
  end;
end;

function Tfrm_ModuleMgr.ModuleType(const ModuleFile: String): TModuleType;
var ext:String;
begin
  ext:=ExtractFileExt(ModuleFile);
  if SameText(ext,'.bpl') then
    Result:=mtBPL
  else if SameText(ext,'.dll') then
    Result:=mtDLL
  else Result:=mtUnknow;
end;

procedure Tfrm_ModuleMgr.UpdateValue(mRec:PModuleRec;Load: Boolean);
const V_Str='Module=%s;Load=%s';
var Value,LoadStr:String;
begin
  if Reg.OpenKey(mRec^.Key) then
  begin
    if Load then
      LoadStr:='True'
    else LoadStr:='False';
    Value:=Format(V_Str,[mRec^.ModuleFileValue,LoadStr]);
    Reg.WriteString(mRec^.Module,Value);
  end;
end;

procedure Tfrm_ModuleMgr.btn_EditClick(Sender: TObject);
var Path:String;
    mRec:PModuleRec;
begin
  if Assigned(self.lv_module.Selected) then
  begin
    if Assigned(self.lv_module.Selected.Data) then
    begin
      mRec:=PModuleRec(self.lv_module.Selected.Data);
      Path:=mRec^.ModuleFileValue;
      if InputQuery('编辑','编辑模块路径:'+#13#10+'($APP_PATH)=程序所在目录',Path) then
      begin
        mRec^.ModuleFileValue:=Path;
        mRec^.ModuleFile:=FormatPath(Path);
        self.UpdateValue(mRec,self.lv_module.Selected.Checked);
        self.lv_module.Selected.SubItems[1]:=Path;
        if FileExists(mRec^.ModuleFile) then
          self.lv_module.Selected.ImageIndex:=3
        else self.lv_module.Selected.ImageIndex:=4;
      end;
    end;
  end;
end;

procedure Tfrm_ModuleMgr.lv_ModuleDblClick(Sender: TObject);
begin
  self.btn_Edit.Click;
end;

procedure Tfrm_ModuleMgr.btn_UnInstalllClick(Sender: TObject);
var mRec:PModuleRec;
begin
  if Assigned(self.lv_module.Selected) then
  begin
    if Assigned(self.lv_module.Selected.Data) then
    begin
      mRec:=PModuleRec(self.lv_module.Selected.Data);
      if FileExists(mRec^.ModuleFile) then
      begin
        if MessageBox(self.Handle,pchar('你确定要卸载['+mRec^.Module+']模块吗？')
          ,'卸载模块',MB_YESNO+MB_ICONQUESTION)<>IDYES then exit;
        Try
          self.UnInstallModule(mRec^.ModuleFile);
          self.lv_module.Selected.Delete;
        Except
          on E:Exception do
            MessageBox(self.Handle,pchar('卸载出错：'+E.Message),'卸载模块',MB_OK+MB_ICONERROR);
        end;
      end else begin
        if MessageBox(self.Handle,pchar('模块['+mRec^.Module
          +']路径不正确，无法卸载，是否直接从注册表删除该模块信息？'),'卸载模块',MB_YESNO+MB_ICONQUESTION)=IDYES then
        begin
          if Reg.OpenKey(mRec^.Key) then
          begin
            Reg.DeleteValue(mRec^.Module);
            self.lv_module.Selected.Delete;
          end;
        end;
      end;
    end;
  end;
end;

procedure Tfrm_ModuleMgr.btn_InstallModuleClick(Sender: TObject);
var i:Integer;
    FileName:string;
begin
  if self.OpenDialog1.Execute then
  begin
    for i:=0 to self.OpenDialog1.Files.Count-1 do
    begin
      try
        FileName:=self.OpenDialog1.Files[i];
        self.InstallModule(FileName);
        //刷新
        self.lv_module.Clear;
        self.DisModuleInList(ModuleKey);
      except
        on E:Exception do
          MessageBox(self.Handle,pchar('安装模块失败：'+E.Message),'安装模块',MB_OK+MB_ICONERROR);
      end;
    end;
  end;
end;

end.
