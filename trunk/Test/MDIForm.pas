unit MDIForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,SvcInfoIntf,uBaseForm,ModuleInfoIntf, ExtCtrls;

type
  TfrmMDI = class(TBaseForm,IModuleInfoGetter,ISvcInfoGetter)
    Memo1: TMemo;
    Panel1: TPanel;
    Button2: TButton;
    Button3: TButton;
    Button1: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    {IModuleInfoGetter}
    procedure ModuleInfo(ModuleInfo:TModuleInfo);
    {ISvcInfoGetter}
    procedure SvcInfo(SvcInfo:TSvcInfoRec);
  public
    { Public declarations }
  end;

var
  frmMDI: TfrmMDI;

implementation

uses SysFactoryMgr,SysSvc,SysInfoIntf,MainFormIntf;

{$R *.dfm}

procedure TfrmMDI.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TfrmMDI.Button2Click(Sender: TObject);
var SvcInfoEx:ISvcInfoEx;
begin
  if SysService.QueryInterface(ISvcInfoEx,SvcInfoEx)=S_OK then
  begin
    self.Memo1.Clear;
    SvcInfoEx.GetSvcInfo(self);
  end;
end;

procedure TfrmMDI.ModuleInfo(ModuleInfo: TModuleInfo);
begin
    Memo1.Lines.Add(Format('%s  %s',[ModuleInfo.PackageName,ModuleInfo.Description]));
end;

procedure TfrmMDI.Button3Click(Sender: TObject);
begin
  Memo1.Clear;
  (SysService as IModuleInfo).GetModuleInfo(self);
end;

procedure TfrmMDI.SvcInfo(SvcInfo: TSvcInfoRec);
begin
  self.Memo1.Lines.Add(Format('%s %s %s %s %s',[SvcInfo.GUID,SvcInfo.ModuleName,SvcInfo.Title,SvcInfo.Version,SvcInfo.Comments]));
end;

procedure TfrmMDI.Button1Click(Sender: TObject);
begin
  (SysService as IFormMgr).CloseForm(self);
end;

end.
