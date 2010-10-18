unit DBConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons,uBaseForm;

type
  TFrm_DBConfig = class(TBaseForm)
    Btn_OK: TBitBtn;
    Btn_Cancel: TBitBtn;
    btn_Constr: TButton;
    mm_ConnStr: TMemo;
    procedure btn_ConstrClick(Sender: TObject);
  private
    procedure SetDBConnStr(const Value: String);
    function GetDBConnStr: String;
    { Private declarations }
  public
    property DBConnStr:String Read GetDBConnStr Write SetDBConnStr;
  end;

var
  Frm_DBConfig: TFrm_DBConfig;

implementation

uses ADODB;

{$R *.dfm}

procedure TFrm_DBConfig.btn_ConstrClick(Sender: TObject);
begin
  self.mm_ConnStr.Text:=PromptDataSource(self.Handle,self.mm_ConnStr.Text);
end;

procedure TFrm_DBConfig.SetDBConnStr(const Value: String);
begin
  self.mm_ConnStr.Text:=value;
end;

function TFrm_DBConfig.GetDBConnStr: String;
begin
  Result:=self.mm_ConnStr.Text;
end;

end.
