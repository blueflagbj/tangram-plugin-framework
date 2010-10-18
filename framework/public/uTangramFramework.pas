{------------------------------------
  功能说明：框架加载单元。只需要在主程序工程文件用本单元替换Forms单元即可加载框架，
            其他的都不需要再改了
  创建日期：2010/10/18
  作者：wei
  版权：wei
-------------------------------------}
unit uTangramFramework;

interface

uses SysUtils,Classes,Forms,Windows,PackageExport;

Type
  TTangramApp=Class
  private
    ProLoad: TLoad;
    ProInit: TInit;
    ProFinal: TFinal;
    FCorePackageHandle: HMODULE;

    function GetFormApp: TApplication;
    function GetTitle: string;
    procedure SetTitle(const Value: string);
    function ReadHintHidePause: Integer;
    procedure WriteHintHidePause(const Value: Integer);
  public
    property Title: string read GetTitle write SetTitle;
    property HintHidePause: Integer read ReadHintHidePause write WriteHintHidePause;
    procedure Initialize;
    procedure CreateForm(InstanceClass: TComponentClass; var Reference);
    procedure Run;
    property FormApp:TApplication Read GetFormApp;

    Constructor Create;
    Destructor Destroy;override;
  end;
var
  Application:TTangramApp;
implementation

{ TTangramApp }

constructor TTangramApp.Create;
var
  CorePackageFile: String[255];
begin
  // 加载核心包
  FCorePackageHandle:=0;
  CorePackageFile := ShortString(ExtractFilePath(Paramstr(0)) + 'Core.bpl');
  if FileExists(String(CorePackageFile)) then
  begin
    FCorePackageHandle := LoadPackage(String(CorePackageFile));
    @ProLoad := GetProcAddress(FCorePackageHandle, 'Load');
    @ProInit := GetProcAddress(FCorePackageHandle, 'Init');
    @ProFinal := GetProcAddress(FCorePackageHandle, 'Final');
  end else
    Forms.Application.MessageBox(pchar('找不到框架核心包[' + String(CorePackageFile)
          + ']，程序无法启动！'), '启动错误', MB_OK + MB_ICONERROR);
end;

procedure TTangramApp.CreateForm(InstanceClass: TComponentClass;
  var Reference);
begin
  Forms.Application.CreateForm(InstanceClass,Reference);
end;

destructor TTangramApp.Destroy;
begin
  // 释放包
  if FCorePackageHandle<>0 then
  begin
    ProFinal;
    UnLoadPackage(FCorePackageHandle);
  end;
  inherited;
end;

function TTangramApp.GetFormApp: TApplication;
begin
  Result:=Forms.Application;
end;

function TTangramApp.GetTitle: string;
begin
  Result:=Forms.Application.Title;
end;

procedure TTangramApp.Initialize;
begin
  Forms.Application.Initialize;
end;

function TTangramApp.ReadHintHidePause: Integer;
begin
  Result:=Forms.Application.HintHidePause;
end;

procedure TTangramApp.Run;
begin
  if FCorePackageHandle=0 then exit;
  ProLoad(Forms.Application.MainForm);
  ProInit;
  Forms.Application.Run;
end;

procedure TTangramApp.SetTitle(const Value: string);
begin
  Forms.Application.Title:=Value;
end;

procedure TTangramApp.WriteHintHidePause(const Value: Integer);
begin
  Forms.Application.HintHidePause:=Value;
end;

initialization
  Application:=TTangramApp.Create;
finalization
  Application.Free;
end.
