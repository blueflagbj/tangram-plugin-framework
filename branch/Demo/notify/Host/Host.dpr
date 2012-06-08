Program Host;

uses
  uTangramFramework,
  uMain in 'uMain.pas' {FrmMain},
  notifyIntf in '..\Interfaces\notifyIntf.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
