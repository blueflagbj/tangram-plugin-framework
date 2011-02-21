unit uFrmWebbrowser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, StdCtrls;

type
  TFrmWebbrowser = class(TForm)
    cb_url: TComboBox;
    Button1: TButton;
    WebBrowser1: TWebBrowser;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmWebbrowser: TFrmWebbrowser;

implementation

{$R *.dfm}

procedure TFrmWebbrowser.Button1Click(Sender: TObject);
begin
  WebBrowser1.Navigate(self.cb_url.Text);
end;

end.
