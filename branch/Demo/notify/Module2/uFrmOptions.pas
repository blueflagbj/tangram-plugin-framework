unit uFrmOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls;

type
  TFrmOptions = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Memo1: TMemo;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmOptions: TFrmOptions;

implementation

{$R *.dfm}

end.
