unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,notifyIntf;

type
  TClsMgr=Class(TObject)
  private
    FFrmCls:TFormClass;
  public
    Constructor Create(FrmClass:TFormClass);
    Destructor Destroy;override;

    function CreateForm(AOwner:TComponent):TForm;
  End;

  TFrmMain = class(TForm,IClsRegister)
    lst_sel: TListBox;
    pnl_view: TPanel;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lst_selClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FCurrFrom:TForm;
    procedure load;
    {IClsRegister}
    procedure RegCls(const aName:string;cls:TFormClass);
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses SysSvc,NotifyServiceIntf;

{$R *.dfm}

procedure TFrmMain.load;
var intf:INotifyService;
begin
  if SysService.QueryInterface(INotifyService,Intf)=S_OK then
  begin
    self.lst_sel.Clear;
    Intf.SendNotify(NotifyFlag,self);
  end;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  FCurrFrom:=nil;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
var i:Integer;
begin
  for i := 0 to self.lst_sel.Items.Count - 1 do
    self.lst_sel.Items.Objects[i].Free;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  load;
end;

procedure TFrmMain.lst_selClick(Sender: TObject);
var ClsMgr:TClsMgr;
    idx:Integer;
begin
  idx:=lst_sel.ItemIndex;
  if idx<>-1 then
  begin
    if FCurrFrom<>nil then
      FCurrFrom.Free;

    ClsMgr:=TClsMgr(self.lst_sel.Items.Objects[idx]);
    FCurrFrom:=ClsMgr.CreateForm(self);
    FCurrFrom.Parent:=self.pnl_view;
    FCurrFrom.BorderStyle:=bsNone;
    FCurrFrom.Align:=alClient;
    FCurrFrom.Show;
  end;
end;

{ TClsMgr }

constructor TClsMgr.Create(FrmClass: TFormClass);
begin
  self.FFrmCls:=FrmClass;
end;

function TClsMgr.CreateForm(AOwner:TComponent): TForm;
begin
  Assert(self.FFrmCls<>nil);
  Result:=self.FFrmCls.Create(AOwner);
end;

destructor TClsMgr.Destroy;
begin

  inherited;
end;

procedure TFrmMain.RegCls(const aName: string; cls: TFormClass);
var ClsMgr:TClsMgr;
begin
  ClsMgr:=TClsMgr.Create(cls);
  self.lst_sel.AddItem(aName,ClsMgr);
end;

end.
