Program SimpleHost;

uses
  uTangramFramework,
  uMain in 'uMain.pas' {FrmMain},
  uIntf in '..\Interfaces\uIntf.pas';

{$R *.res}

begin
  Application.Initialize;
  {$IFDEF VER210}
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  {$ENDIF}
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
