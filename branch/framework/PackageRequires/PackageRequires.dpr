program PackageRequires;

uses
  Forms,
  uMain in 'uMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '包引用查看工具';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
