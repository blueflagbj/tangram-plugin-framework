program MainAPP2;

uses
  FastMM4,//注意：在Delphi7下如果不用FastMM4点窗件上的"关闭"按扭关闭页签可能会出一个abstract error错误
          //目前暂时没找到原因，因此建议到网上下载FastMM4
  Forms,
  sysUtils,
  Windows,
  MainFormIntf,
  uMain in 'uMain.pas' { frm_Main } ,
  ExceptionHandle in 'ExceptionHandle.pas' { frm_Exception } ,
  PackageExport in '..\Public\PackageExport.pas';
{$R *.res}

var
  CorePackageFile: String[255]; // 这里如果声明成长字符串型(string)FastMM会检测到有内存泄漏
  ProLoad: TLoad;
  ProInit: TInit;
  ProFinal: TFinal;
  FCorePackageHandle: HMODULE;

begin
  Application.Initialize;
  {$IFDEF VER210}
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  Application.MainFormOnTaskbar := True;
  {$ENDIF}
  Application.Title := '框架主程序';
  Application.HintHidePause := 1000 * 30;
  Application.CreateForm(Tfrm_Main, frm_Main);
  // 加载核心包
  CorePackageFile := ShortString(ExtractFilePath(Paramstr(0)) + 'Core.bpl');
  if FileExists(String(CorePackageFile)) then
  begin
    FCorePackageHandle := LoadPackage(String(CorePackageFile));
    @ProLoad := GetProcAddress(FCorePackageHandle, 'Load');
    @ProInit := GetProcAddress(FCorePackageHandle, 'Init');

    if assigned(ProLoad) then
    begin
      Try
        ProLoad(frm_Main);
      Except
        on E: Exception do
          Application.ShowException(E);
      End;
    end;

    if assigned(ProInit) then
    begin
      try
        ProInit;
      Except
        on E: Exception do
          Application.ShowException(E);
      end;
    end;

    Application.Run;
    // 先关掉所有打开的子窗体，不然先释放包会报地址错
    frm_Main.ReleaseForms;
    // 程序结束
    @ProFinal := GetProcAddress(FCorePackageHandle, 'Final');
    if assigned(ProFinal) then
    begin
      try
        ProFinal;
      Except
        on E: Exception do
          Application.ShowException(E);
      end;
    end;
    // 释放包
    UnLoadPackage(FCorePackageHandle);
  end
  else
    Application.MessageBox(pchar('找不到框架核心包[' + String(CorePackageFile)
          + ']，程序无法启动！'), '启动错误', MB_OK + MB_ICONERROR);

end.
