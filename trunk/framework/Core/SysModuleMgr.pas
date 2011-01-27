{ ------------------------------------
  功能说明：模块管理
  创建日期：2010/05/11
  作者：wzw
  版权：wzw
  ------------------------------------- }
unit SysModuleMgr;

interface

uses SysUtils, Classes, Windows, Contnrs, RegIntf, SplashFormIntf,
  ModuleInfoIntf, SvcInfoIntf, PluginBase;

Type
  TGetPluginClassPro = function :TPluginClass;

  TModuleType=(mtUnknow,mtBPL,mtDLL);

  TModuleLoader = Class(TInterfacedObject)
  private
    FModuleHandle: HMODULE;
    FModuleFileName: String;
    FPlugin: TPlugin;
    function GetModuleType: TModuleType;
    function LoadModule:THandle;
    procedure UnLoadModule;
  protected

  public
    Constructor Create(const mFile: String);
    Destructor Destroy; override;
    function ContainPlugin: Boolean;

    property Plugin: TPlugin Read FPlugin;
    property ModuleFileName: String Read FModuleFileName;
    property ModuleType:TModuleType Read GetModuleType;
  End;

  TModuleMgr = Class(TPersistent, IInterface, IModuleInfo, ISvcInfo)
  private
    SplashForm: ISplashForm;
    Tick: Integer;
    FModuleList: TObjectList;
    procedure WriteErrFmt(const err: String; const Args: array of const );
    function FormatPath(const s: string): string;
    procedure GetModuleList(RegIntf: IRegistry; ModuleList: TStrings;
      const Key: String);
    procedure LoadModuleFromFile(const ModuleFile: string);
  protected
    FRefCount: Integer;
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    { IModuleInfo }
    procedure GetModuleInfo(ModuleInfoGetter: IModuleInfoGetter);
    procedure PluginRegister(Flags: Integer; Intf: IInterface);
    { ISvcInfo }
    function GetModuleName: String;
    function GetTitle: String;
    function GetVersion: String;
    function GetComments: String;
  public
    Constructor Create;
    Destructor Destroy; override;

    procedure LoadModules;
    procedure Init;
    procedure final;
  end;

implementation

uses uConst, SysSvc, LogIntf, LoginIntf, StdVcl, AxCtrls, SysFactoryMgr,
  SysFactory,IniFiles,RegObj,uSvcInfoObj;

procedure CreateRegObj(out anInstance: IInterface);
var RegFile,IniFile,AppPath:String;
    Ini:TIniFile;
begin
  AppPath:=ExtractFilePath(ParamStr(0));
  IniFile:=AppPath+'Root.ini';
  ini:=TIniFile.Create(IniFile);
  try
    RegFile:=AppPath+ini.ReadString('Default','Reg','');
    anInstance:=TRegObj.Create;
    (anInstance as ILoadRegistryFile).LoadRegistryFile(RegFile);
  finally
    ini.Free;
  end;
end;

procedure Create_SvcInfoObj(out anInstance: IInterface);
begin
  anInstance:=TSvcInfoObj.Create;
end;
{ TModuleLoader }

function TModuleLoader.ContainPlugin: Boolean;
begin
  Result := FPlugin <> nil;
end;

constructor TModuleLoader.Create(const mFile: String);
var
  GetPluginClassPro: TGetPluginClassPro;
  PluginCls:TPluginClass;
begin
  FPlugin := nil;
  FModuleFileName := mFile;
  FModuleHandle := self.LoadModule;
  @GetPluginClassPro := GetProcAddress(FModuleHandle, 'GetPluginClass');
  PluginCls:=GetPluginClassPro;
  if PluginCls<>nil then
    FPlugin:=PluginCls.Create;
end;

destructor TModuleLoader.Destroy;
begin
  if Assigned(FPlugin) then
    FPlugin.Free;

  self.UnLoadModule;
  inherited;
end;

function TModuleLoader.GetModuleType: TModuleType;
var ext:String;
begin
  ext:=ExtractFileExt(self.FModuleFileName);
  if SameText(ext,'.bpl') then
    Result:=mtBPL
  else Result:=mtDLL;
end;

function TModuleLoader.LoadModule: THandle;
begin
  Result:=0;
  case GetModuleType of
    mtBPL:Result:=SysUtils.LoadPackage(self.FModuleFileName);
    mtDLL:Result:=Windows.LoadLibrary(Pchar(self.FModuleFileName));
  end;
end;

procedure TModuleLoader.UnLoadModule;
begin
  case GetModuleType of
    mtBPL:SysUtils.UnloadPackage(self.FModuleHandle);
    mtDLL:Windows.FreeLibrary(self.FModuleHandle);
  end;
end;

{ TModuleMgr }

function TModuleMgr.GetComments: String;
begin
  Result := '用于获取当前系统加载包的信息及初始化包。';
end;

function TModuleMgr.GetModuleName: String;
begin
  Result := ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TModuleMgr.GetTitle: String;
begin
  Result := '模块信息接口(IModuleInfo)';
end;

function TModuleMgr.GetVersion: String;
begin
  Result := '20100512.001';
end;

constructor TModuleMgr.Create;
begin
  FModuleList := TObjectList.Create(True);

  TIntfFactory.Create(IRegistry,@CreateRegObj);
  TObjFactory.Create(IModuleInfo, self);
  TIntfFactory.Create(ISvcInfoEx,@Create_SvcInfoObj);
end;

destructor TModuleMgr.Destroy;
begin
  //释放工厂里的对象实例
  FactoryManager.ReleaseInstances;

  FModuleList.Free;
  inherited;
end;

function TModuleMgr.FormatPath(const s: string): string;
const
  Var_AppPath = '($APP_PATH)';
begin
  Result := StringReplace(s, Var_AppPath, ExtractFilePath(Paramstr(0)),
    [rfReplaceAll, rfIgnoreCase]);
end;

procedure TModuleMgr.GetModuleList(RegIntf: IRegistry; ModuleList: TStrings;
  const Key: String);
var
  SubKeyList, ValueList, aList: TStrings;
  i: Integer;
  valueStr: string;
  valueName, vStr, ModuleFile, Load: WideString;
begin
  SubKeyList := TStringList.Create;
  ValueList := TStringList.Create;
  aList := TStringList.Create;
  try
    RegIntf.OpenKey(Key, False);
    // 处理值
    RegIntf.GetValueNames(ValueList);
    for i := 0 to ValueList.Count - 1 do
    begin
      aList.Clear;
      valueName := ValueList[i];
      if RegIntf.ReadString(valueName, vStr) then
      begin
        valueStr := AnsiUpperCase(vStr);
        ExtractStrings([';'], [], pchar(valueStr), aList);
        ModuleFile := FormatPath(aList.Values[Value_Module]);
        Load := aList.Values[Value_Load];
        if (ModuleFile <> '') and (CompareText(Load, 'TRUE') = 0) then
          ModuleList.Add(ModuleFile);
      end;
    end;
    // 向下查找
    RegIntf.GetKeyNames(SubKeyList);
    for i := 0 to SubKeyList.Count - 1 do
      GetModuleList(RegIntf, ModuleList, Key + '\' + SubKeyList[i]); // 递归
  finally
    SubKeyList.Free;
    ValueList.Free;
    aList.Free;
  end;
end;

procedure TModuleMgr.PluginRegister(Flags: Integer; Intf: IInterface);
var
  i: Integer;
  PluginLoader: TModuleLoader;
begin
  for i := 0 to FModuleList.Count - 1 do
  begin
    PluginLoader := TModuleLoader(FModuleList[i]);
    if not PluginLoader.ContainPlugin then
      Continue;

    try
      PluginLoader.Plugin.Register(Flags, Intf);
    except
      on E: Exception do
        WriteErrFmt('处理插件Register方法出错([%s])：%s',
          [ExtractFileName(PluginLoader.ModuleFileName), E.Message]);
    end;
  end;
end;

procedure TModuleMgr.GetModuleInfo(ModuleInfoGetter: IModuleInfoGetter);
var
  i: Integer;
  PluginLoader: TModuleLoader;
  MInfo: TModuleInfo;
begin
  if ModuleInfoGetter = nil then
    exit;
  for i := 0 to FModuleList.Count - 1 do
  begin
    PluginLoader := TModuleLoader(FModuleList[i]);
    MInfo.PackageName := PluginLoader.ModuleFileName;
    MInfo.Description := GetPackageDescription(pchar(MInfo.PackageName));
    ModuleInfoGetter.ModuleInfo(MInfo);
  end;
end;

procedure TModuleMgr.Init;
var
  i, CurTick, WaitTime: Integer;
  LoginIntf: ILogin;
  PluginLoader: TModuleLoader;
begin
  PluginLoader := nil;
  for i := 0 to FModuleList.Count - 1 do
  begin
    Try
      PluginLoader := TModuleLoader(FModuleList.Items[i]);
      if not PluginLoader.ContainPlugin then
        Continue;

      if Assigned(SplashForm) then
        SplashForm.loading(Format('正在初始化包[%s]',
            [ExtractFileName(PluginLoader.ModuleFileName)]));

      PluginLoader.Plugin.Init;
    Except
      on E: Exception do
      begin
        WriteErrFmt('处理插件Init方法出错([%s])，错误：%s',
          [ExtractFileName(PluginLoader.ModuleFileName), E.Message]);
      end;
    End;
  end;
  // 隐藏Splash窗体
  if Assigned(SplashForm) then
  begin
    CurTick := GetTickCount;
    WaitTime := CurTick - Tick;
    if WaitTime < SplashFormWaitTime then
    begin
      SplashForm.loading('正准备进入系统，请稍等...');
      sleep(SplashFormWaitTime - WaitTime);
    end;

    SplashForm.Hide;
    FactoryManager.UnRegisterFactory(ISplashForm);
    SplashForm := nil;
  end;
  // 检查登录
  if SysService.QueryInterface(ILogin, LoginIntf) = S_OK then
    LoginIntf.CheckLogin;
end;

procedure TModuleMgr.LoadModules;
var
  aList: TStrings;
  i: Integer;
  RegIntf: IRegistry;
  ModuleFile: String;
begin
  // 加载其他包
  aList := TStringList.Create;
  try
    SplashForm := nil;
    RegIntf := SysService as IRegistry;
    GetModuleList(RegIntf, aList, key_LoadModule);
    for i := 0 to aList.Count - 1 do
    begin
      ModuleFile := aList[i];
      // 加载包
      if FileExists(ModuleFile) then
        LoadModuleFromFile(ModuleFile)
      else
        WriteErrFmt('找不到包[%s]，无法加载！', [ModuleFile]);

      if Assigned(SplashForm) then
        SplashForm.loading(Format('正在加载包[%s]...',
            [ExtractFileName(ModuleFile)]));
      // 显示Falsh窗体
      if SplashForm = nil then
      begin
        if SysService.QueryInterface(ISplashForm, SplashForm) = S_OK then
        begin
          Tick := GetTickCount;
          SplashForm.Show;
        end;
      end;
    end;
  finally
    aList.Free;
  end;
end;

procedure TModuleMgr.LoadModuleFromFile(const ModuleFile: string);
begin
  try
    FModuleList.Add(TModuleLoader.Create(ModuleFile));
  Except
    on E: Exception do
    begin
      WriteErrFmt('加载包[%s]出错，错误：%s', [ExtractFileName(ModuleFile), E.Message]);
    end;
  end;
end;

function TModuleMgr.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TModuleMgr.final;
var
  i: Integer;
  ModuleLoader: TModuleLoader;
begin
  for i := 0 to FModuleList.Count - 1 do
  begin
    ModuleLoader := TModuleLoader(FModuleList.Items[i]);
    if ModuleLoader.ContainPlugin then
    begin
      try
        ModuleLoader.Plugin.final;
      Except
        //处理...
      end;
    end;
  end;
end;

procedure TModuleMgr.WriteErrFmt(const err: String;
  const Args: array of const );
var
  Log: ILog;
begin
  if SysService.QueryInterface(ILog, Log) = S_OK then
    Log.WriteErrFmt(err, Args);
end;

function TModuleMgr._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TModuleMgr._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
end;

initialization

finalization

end.
