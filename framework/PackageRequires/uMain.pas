unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, ComCtrls, ToolWin, ImgList;

type
  TItemInfo=Class
    PackageFullName:String;
  end;
  TfrmMain = class(TForm)
    lis_Package: TListBox;
    lis_RequirePackage: TListBox;
    ToolBar1: TToolBar;
    btn_Open: TToolButton;
    btn_clear: TToolButton;
    btn_view: TToolButton;
    btn_exp: TToolButton;
    ToolButton5: TToolButton;
    OpenDialog1: TOpenDialog;
    ProgressBar1: TProgressBar;
    ImageList1: TImageList;
    btn_Del: TToolButton;
    procedure btn_OpenClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn_clearClick(Sender: TObject);
    procedure btn_viewClick(Sender: TObject);
    procedure btn_expClick(Sender: TObject);
    procedure btn_DelClick(Sender: TObject);
  private
    procedure DoGetPackageInfo(const PackageFile:String);
    procedure ClearList(aList:TStrings);
  public
    procedure PutPackageFileToList(const PackageFileName:String);
  end;

var
  frmMain: TfrmMain;

implementation

uses FileCtrl,ShellAPI;

{$R *.dfm}
function SearchFile(var FileName:String):Boolean;
var Buffer: array[0..MAX_PATH - 1] of Char;
    FName:Pchar;
begin
  Result:=SearchPath(nil, pchar(FileName), nil, Length(Buffer), Buffer, FName)<>0;
  if Result then FileName:=Buffer;
end;

procedure PckageInfo(const Name: string; NameType: TNameType; Flags: Byte; Param: Pointer);
begin
  if NameType=ntRequiresPackage then
    frmMain.PutPackageFileToList(Name);
end;

procedure TfrmMain.ClearList(aList: TStrings);
var i:Integer;
begin
  for i:=0 to aList.Count-1 do
    aList.Objects[i].Free;
  aList.Clear;
end;

procedure TfrmMain.DoGetPackageInfo(const PackageFile: String);
var h:HMODULE;
    f:Integer;
begin
  h:=SafeLoadLibrary(PackageFile);//LoadPackage
  try
    f:=0;
    SysUtils.GetPackageInfo(h,nil,f,@PckageInfo);
  finally
    FreeLibrary(h);//UnLoadPackage
  end;
end;

procedure TfrmMain.btn_OpenClick(Sender: TObject);
var i,idx:Integer;
    ItemInfo:TItemInfo;
    s:String;
begin
  self.OpenDialog1.InitialDir:=ExtractFilePath(paramStr(0));
  if self.OpenDialog1.Execute then
  begin
    for i:=0 to self.OpenDialog1.Files.Count-1 do
    begin
      s:=ExtractFileName(self.OpenDialog1.Files[i]);
      idx:=lis_Package.Items.IndexOf(s);
      if idx=-1 then
      begin
        ItemInfo:=TItemInfo.Create;
        ItemInfo.PackageFullName:=self.OpenDialog1.Files[i];
        lis_Package.Items.AddObject(s,ItemInfo);
      end;
    end;
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  ClearList(self.lis_Package.Items);
end;

procedure TfrmMain.btn_clearClick(Sender: TObject);
begin
  ClearList(self.lis_Package.Items);
end;

procedure TfrmMain.btn_viewClick(Sender: TObject);
var i:integer;
    ItemInfo:TItemInfo;
begin
  self.lis_RequirePackage.Clear;
  ProgressBar1.Max:=self.lis_Package.Items.Count;
  for i:=0 to self.lis_Package.Items.Count-1 do
  begin
    ProgressBar1.Position:=i;
    ItemInfo:=TItemInfo(self.lis_Package.Items.Objects[i]);
    self.DoGetPackageInfo(ItemInfo.PackageFullName);
  end;
  ProgressBar1.Position:=0;
end;

procedure TfrmMain.PutPackageFileToList(const PackageFileName: String);
var  idx:Integer;
begin
  idx:=self.lis_RequirePackage.Items.IndexOf(PackageFileName);
  if idx=-1 then
    self.lis_RequirePackage.Items.Add(PackageFileName);
end;

procedure TfrmMain.btn_expClick(Sender: TObject);
var dir,s,FullName,toName:string;
    i:Integer;
begin
  if lis_RequirePackage.Items.Count=0 then exit;
  if SelectDirectory('选择导出目录:', '', Dir) then
  begin
    for i:=0 to self.lis_RequirePackage.Items.Count-1 do
    begin
      s:=self.lis_RequirePackage.Items[i];
      FullName:=s;
      if SearchFile(FullName) then
      begin
        toName:=Dir+'\'+s;
        CopyFile(pchar(FullName),pchar(toName),False);
      end else MessageBox(self.Handle,pchar('找不到'+FullName+'包！'),'错误',MB_OK+MB_ICONERROR);
    end;
    if MessageBox(self.Handle,'已经导出到指定目录，是否打开该目录？','导出完成',MB_YESNO+MB_ICONQUESTION)=IDYES then
      shellexecute(application.Handle,'open',pchar(Dir),nil,nil,SW_SHOWNORMAL);
  end;
end;

procedure TfrmMain.btn_DelClick(Sender: TObject);
var idx:Integer;
begin
  idx:=lis_Package.ItemIndex;
  if idx<>-1 then
  begin
    lis_Package.Items.Objects[idx].Free;
    lis_Package.DeleteSelected;
  end;
end;

end.
