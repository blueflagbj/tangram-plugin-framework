program MainAPP2;

uses
  //FastMM4,//一定要引用FastMM4，不然点"关闭"窗口时会出现一个abstract错误，
          //目前暂未找到原因
  uTangramFramework,
  uMain in 'uMain.pas' { frm_Main },
  ExceptionHandle in 'ExceptionHandle.pas' { frm_Exception };

{$R *.res}

begin
  Application.Initialize;
  {$IFDEF VER210}
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  //Application.MainFormOnTaskbar := True;
  {$ENDIF}
  Application.Title := '框架主程序';
  Application.HintHidePause := 1000 * 30;
  Application.CreateForm(Tfrm_Main, frm_Main);
  Application.Run;
end.
