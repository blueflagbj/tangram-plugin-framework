unit uNewImpIntfUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TFrmNewImptUntfUnit = class(TForm)
    Label1: TLabel;
    edt_className: TEdit;
    Label2: TLabel;
    cb_Factory: TComboBox;
    GroupBox1: TGroupBox;
    chk_IntfInfo: TCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Edt_IntfName: TEdit;
    edt_IntfVer: TEdit;
    mm_IntfComments: TMemo;
    btn_OK: TBitBtn;
    btn_Cancel: TBitBtn;
    procedure btn_OKClick(Sender: TObject);
    procedure chk_IntfInfoClick(Sender: TObject);
  private
    FEnableIntfInfo: Boolean;
    procedure SetEnableIntfInfo(const Value: Boolean);
  public
    property EnableIntfInfo:Boolean Read FEnableIntfInfo Write SetEnableIntfInfo;
  end;

var
  FrmNewImptUntfUnit: TFrmNewImptUntfUnit;

implementation

{$R *.dfm}

procedure TFrmNewImptUntfUnit.btn_OKClick(Sender: TObject);
begin
  if trim(edt_className.Text)='' then
  begin
    MessageBox(self.Handle,'类名不能为空！','提示',MB_OK+MB_ICONWARNING);
    edt_className.SetFocus;
    exit;
  end;
  if chk_IntfInfo.Checked then
  begin
    if Trim(Edt_IntfName.Text)='' then
    begin
      MessageBox(self.Handle,'请输入接口名称！','提示',MB_OK+MB_ICONWARNING);
      Edt_IntfName.SetFocus;
      exit;
    end;
  end;
  self.ModalResult:=mrOK;
end;

procedure TFrmNewImptUntfUnit.SetEnableIntfInfo(const Value: Boolean);
begin
  FEnableIntfInfo := Value;
  if FEnableIntfInfo then
  begin
    Edt_IntfName.ReadOnly:=False;
    Edt_IntfName.Color:=clWindow;
    edt_IntfVer.ReadOnly:=False;
    edt_IntfVer.Color:=clWindow;
    mm_IntfComments.ReadOnly:=False;
    mm_IntfComments.Color:=clWindow;
  end else begin
    Edt_IntfName.ReadOnly:=True;
    Edt_IntfName.Color:=self.Color;
    edt_IntfVer.ReadOnly:=True;
    edt_IntfVer.Color:=self.Color;
    mm_IntfComments.ReadOnly:=True;
    mm_IntfComments.Color:=self.Color;
  end;
end;

procedure TFrmNewImptUntfUnit.chk_IntfInfoClick(Sender: TObject);
begin
  self.EnableIntfInfo:=self.chk_IntfInfo.Checked;

  if self.EnableIntfInfo then
  begin
    if Edt_IntfName.Text='' then
      Edt_IntfName.Text:='例如:注册表接口(IRegistry)';

    if edt_IntfVer.Text='' then
      edt_IntfVer.Text:=FormatDateTime('yyyymmdd',now)+'.001';
  end;
end;

end.
