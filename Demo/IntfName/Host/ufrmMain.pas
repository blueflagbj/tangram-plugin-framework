unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private

  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation 

uses SysSvc,ObjRefIntf,ShowFormIntf;

{$R *.dfm}


procedure TFrmMain.Button1Click(Sender: TObject);
begin
  (SysService('Form1') as IShowForm).show;
end;

procedure TFrmMain.Button2Click(Sender: TObject);
begin
  (SysService('Form2') as IShowForm).show;
end;

end.