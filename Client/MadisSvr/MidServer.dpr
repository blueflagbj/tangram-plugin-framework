program MidServer;

uses
  Forms,
  uMain in 'uMain.pas' {Form1},
  MidServer_TLB in 'MidServer_TLB.pas',
  uTestSvr in 'uTestSvr.pas' {DM: TRemoteDataModule} {Test: CoClass};

{$R *.TLB}

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
