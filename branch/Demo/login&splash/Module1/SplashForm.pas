unit SplashForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  Tfrm_Splash = class(TForm)
    lab_Title: TLabel;
    mm_Loading: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_Splash: Tfrm_Splash;

implementation

{$R *.dfm}

end.
