unit SplashForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls,uBaseForm;

type
  Tfrm_Splash = class(TBaseForm)
    lab_ver: TLabel;
    lab_Title: TLabel;
    lab_Right: TLabel;
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
