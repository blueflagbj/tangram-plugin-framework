unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,uTestIntf,ModuleLoaderIntf;

type
  TFrmMain = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses SysSvc;

{$R *.dfm}

procedure TFrmMain.Button1Click(Sender: TObject);
begin
  (SysService as Itest).test;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var ModuleLoader:IModuleLoader;
begin
  //首先在工程文件加上Application.LoadModuleFromRegistry:=False;
  // 这样框架就不会自动加载模块了

  ModuleLoader:=SysService as IModuleLoader; //获取IModuleLoader接口

  ModuleLoader.LoadModulesFromDir();//从指定目录加载模块，如果目录为空，则从当前程序目录加载模块
  ModuleLoader.LoadFinish;//加载完成后，记得调LoadFinish，这样TPlugin.Init才会被执行
end;

end.
