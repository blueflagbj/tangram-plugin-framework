Program SimpleHost;

uses
  uTangramFramework,
  uMain in 'uMain.pas' {FrmMain},
  uIntf in '..\Interfaces\uIntf.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
