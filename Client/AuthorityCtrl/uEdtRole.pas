unit uEdtRole;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseForm, StdCtrls, Buttons,DBIntf;

type
  TFrmEdtRole = class(TBaseForm)
    Label1: TLabel;
    Label2: TLabel;
    edt_RoleName: TEdit;
    edt_Description: TEdit;
    btn_OK: TBitBtn;
    btn_Cancel: TBitBtn;
    procedure btn_OKClick(Sender: TObject);
  private
    FRec:IDataRecord;
  public
    Constructor Create(AOwner:TComponent;Rec:IDataRecord);ReIntroduce;
    property ResultData:IDataRecord Read FRec;
  end;

var
  FrmEdtRole: TFrmEdtRole;

implementation

uses SysSvc,_sys;

{$R *.dfm}

procedure TFrmEdtRole.btn_OKClick(Sender: TObject);
begin
  inherited;
  if edt_RoleName.Text='' then
  begin
    sys.Dialogs.Warning('角色名称不能为空！');
    edt_RoleName.SetFocus;
    exit;
  end;

  FRec.FieldValues['RoleName']   :=self.edt_RoleName.Text;
  FRec.FieldValues['Description']:=self.edt_Description.Text;

  self.ModalResult:=mrOK;
end;

constructor TFrmEdtRole.Create(AOwner: TComponent; Rec: IDataRecord);
begin
  Inherited Create(AOwner);
  if Assigned(Rec) then
  begin
    FRec:=Rec;
    self.edt_RoleName.Text   :=FRec.FieldValueAsString('RoleName');
    self.edt_Description.Text:=FRec.FieldValueAsstring('Description');
  end else FRec:=SysService as IDataRecord;
end;

end.
