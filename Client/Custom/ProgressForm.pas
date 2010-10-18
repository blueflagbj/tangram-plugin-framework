unit ProgressForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, uBaseForm;

type
  Tfrm_ProgressForm = class(TBaseForm)
    pal_Msg: TPanel;
    ProgressBar: TProgressBar;
    Animate1: TAnimate;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//var
//  frm_ProgressForm: Tfrm_ProgressForm;

implementation

{$R *.dfm}

procedure Tfrm_ProgressForm.FormCreate(Sender: TObject);
begin
  Animate1.Active:=True;
  ProgressBar.Visible:=False;
  self.pal_Msg.DoubleBuffered:=true;
end;

end.
