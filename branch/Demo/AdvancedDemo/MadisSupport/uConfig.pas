unit uConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBaseForm, StdCtrls, Buttons;

type
  TfrmConfig = class(TBaseForm)
    Label1: TLabel;
    Label2: TLabel;
    btn_OK: TBitBtn;
    btn_Cancel: TBitBtn;
    edt_IPAddr: TEdit;
    edt_Port: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfig: TfrmConfig;

implementation

{$R *.dfm}

end.
