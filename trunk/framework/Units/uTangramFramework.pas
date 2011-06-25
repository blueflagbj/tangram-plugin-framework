{------------------------------------
  功能说明：框架加载单元。只需要在主程序工程文件用本单元替换Forms单元即可加载框架，
            其他的都不需要再改了
  创建日期：2010/10/18
  作者：wei
  版权：wei
-------------------------------------}
unit uTangramFramework;

interface

uses SysUtils,Classes,Forms,Windows,SysModuleMgr;

Type
  TTangramApp=Class
  private
    FModuleMgr:TModuleMgr;
    FLoadModuleFromRegistry: Boolean;

    function GetFormApp: TApplication;
    function GetTitle: string;
    procedure SetTitle(const Value: string);
    function ReadHintHidePause: Integer;
    procedure WriteHintHidePause(const Value: Integer);
    function GetMainFormOnTaskbar: Boolean;
    procedure SetMainFormOnTaskbar(const Value: Boolean);
  public
    property Title: string read GetTitle write SetTitle;
    property HintHidePause: Integer read ReadHintHidePause write WriteHintHidePause;
    procedure Initialize;
    procedure CreateForm(InstanceClass: TComponentClass; var Reference);
    procedure Run;
    property FormApp:TApplication Read GetFormApp;
    property MainFormOnTaskbar:Boolean Read GetMainFormOnTaskbar Write SetMainFormOnTaskbar;
    Constructor Create;
    Destructor Destroy;override;

    property LoadModuleFromRegistry:Boolean Read FLoadModuleFromRegistry Write FLoadModuleFromRegistry;
  end;
var
  Application:TTangramApp;
implementation

{ TTangramApp }

constructor TTangramApp.Create;
begin
  FLoadModuleFromRegistry:=True;
  FModuleMgr:=TModuleMgr.Create;
end;

procedure TTangramApp.CreateForm(InstanceClass: TComponentClass;
  var Reference);
begin
  Forms.Application.CreateForm(InstanceClass,Reference);
end;

destructor TTangramApp.Destroy;
begin
  FModuleMgr.Free;
  inherited;
end;

function TTangramApp.GetFormApp: TApplication;
begin
  Result:=Forms.Application;
end;

function TTangramApp.GetMainFormOnTaskbar: Boolean;
begin
  {$IFDEF VER210}
  Result:=Forms.Application.MainFormOnTaskbar;
  {$ENDIF}
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
  if FLoadModuleFromRegistry then
  begin
    FModuleMgr.LoadModules;
    FModuleMgr.Init;
  end;
  Forms.Application.Run;
  FModuleMgr.final;
end;

procedure TTangramApp.SetMainFormOnTaskbar(const Value: Boolean);
begin
  {$IFDEF VER210}
  Forms.Application.MainFormOnTaskbar:=Value;
  {$ENDIF}
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
