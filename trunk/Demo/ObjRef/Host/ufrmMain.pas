unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure ShowForm(param:Integer);
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation 

uses SysSvc,ObjRefIntf,TestIntf;

{$R *.dfm}

procedure TFrmMain.ShowForm(param: Integer);
var ObjRef:IObjRef;
begin
  if SysService('',param).GetObjRef(Itest,ObjRef) then
  begin
    if not ObjRef.ObjIsNil then
      TForm(ObjRef.Obj).ShowModal;
  end;
end;

procedure TFrmMain.Button1Click(Sender: TObject);
begin
  self.ShowForm(1);
end;

procedure TFrmMain.Button2Click(Sender: TObject);
begin
  self.ShowForm(2);
end;

end.