unit editValue;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  Tfrm_EditValue = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    edt_Name: TEdit;
    edt_Value: TEdit;
    btn_Ok: TBitBtn;
    btn_Cancel: TBitBtn;
    procedure btn_OkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_EditValue: Tfrm_EditValue;

implementation

{$R *.dfm}

procedure Tfrm_EditValue.btn_OkClick(Sender: TObject);
begin
  if trim(edt_Name.text)='' then
  begin
    showmessage('请输入值名称！');
    exit;
  end;
  if Pos(':',edt_Name.Text)>0 then
  begin
    showmessage('名称不能包含'':''!');
    exit;
  end;
  {if edt_Value.Text='' then
  begin
    showmessage('请输入值！');
    exit;
  end; }
  self.ModalResult:=mrOK;
end;

end.
