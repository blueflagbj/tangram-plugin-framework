{ ------------------------------------
  功能说明：模块管理
  创建日期：2010/05/11
  作者：wzw
  版权：wzw
  ------------------------------------- }
unit SysModuleMgr;

interface

uses SysUtils, Classes, Windows, Contnrs, RegIntf, SplashFormIntf,
  ModuleInfoIntf, SvcInfoIntf, PluginBase,ModuleLoaderIntf,StrUtils;

Type
  TGetPluginClassPro = function :TPluginClass;

  TModuleType=(mtUnknow,mtBPL,mtDLL);

  TModuleLoader = Class(TInterfacedObject)
  private
    FLoadBatch:String;
    FModuleHandle: HMODULE;
    FModuleFileName: String;
    FPlugin: TPlugin;
    function GetModuleType: TModuleType;
    function LoadModule:THandle;
    procedure UnLoadModule;
  protected

  public
    Constructor Create(const mFile: String;LoadBatch:String='');
    Destructor Destroy; override;

    property ModuleFileName: String Read FModuleFileName;
    property ModuleType:TModuleType Read GetModuleType;

    procedure ModuleNotify(Flags: Integer; Intf: IInterface);
    procedure ModuleInit(const LoadBatch:String);
    procedure ModuleFinal;
  End;

  TModuleMgr = Class(TPersistent, IInterface, IModuleInfo,
    IModuleLoader, ISvcInfoEx)
  private
    SplashForm: ISplashForm;
    Tick: Integer;
    FModuleList: TObjectList;
    FLoadBatch:String;
    procedure WriteErrFmt(const err: String; const Args: array of const );
    function FormatPath(const s: string): string;
    procedure GetModuleList(RegIntf: IRegistry; ModuleList: TStrings;
      const Key: String);
    {IModuleLoader}
    procedure LoadBegin;
    procedure LoadModuleFromFile(const ModuleFile: string);
    procedure LoadModulesFromDir(const Dir:String='');
    procedure LoadFinish;
  protected
    FRefCount: Integer;
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    { IModuleInfo }
    procedure GetModuleInfo(ModuleInfoGetter: IModuleInfoGetter);
    procedure PluginNotify(Flags: Integer; Intf: IInterface);
    { ISvcInfoEx }
    procedure GetSvcInfo(Intf:ISvcInfoGetter);
  public
    Constructor Create;
    Destructor Destroy; override;

    procedure LoadModules;
    procedure Init;
    procedure final;
  end;

implementation

uses SysSvc, LogIntf, LoginIntf, StdVcl, AxCtrls, SysFactoryMgr,
  SysFactory,SysFactoryEx,IniFiles,RegObj,uSvcInfoObj;

{$WARN SYMBOL_DEPRECATED OFF}
{$WARN SYMBOL_PLATFORM OFF}
const
  Value_Module='Module';
  Value_Load='LOAD';
  SplashFormWaitTime=1500;
  key_LoadModule='SYSTEM\LOADMODULE';

procedure CreateRegObj(out anInstance: IInterface);
var RegFile,IniFile,AppPath:String;
    Ini:TIniFile;
begin
  AppPath:=ExtractFilePath(ParamStr(0));
  IniFile:=AppPath+'Root.ini';
  ini:=TIniFile.Create(IniFile);
  try
    RegFile:=AppPath+ini.ReadString('Default','Reg','Tangram.xml');
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

constructor TModuleLoader.Create(const mFile: String;LoadBatch:String='');
var
  GetPluginClassPro: TGetPluginClassPro;
  PluginCls:TPluginClass;
begin
  FPlugin := nil;
  FLoadBatch:=LoadBatch;
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

procedure TModuleLoader.ModuleFinal;
begin
  if FPlugin<>nil then
    FPlugin.final;
end;

procedure TModuleLoader.ModuleInit(const LoadBatch: String);
begin
  if FPlugin<>nil then
  begin
    if self.FLoadBatch=LoadBatch then
      FPlugin.Init;
  end;
end;

procedure TModuleLoader.ModuleNotify(Flags: Integer; Intf: IInterface);
begin
  if FPlugin<>nil then
    FPlugin.Notify(Flags,Intf);
end;

procedure TModuleLoader.UnLoadModule;
begin
  case GetModuleType of
    mtBPL:SysUtils.UnloadPackage(self.FModuleHandle);
    mtDLL:Windows.FreeLibrary(self.FModuleHandle);
  end;
end;

{ TModuleMgr }

procedure TModuleMgr.GetSvcInfo(Intf: ISvcInfoGetter);
var SvrInfo:TSvcInfoRec;
begin
  SvrInfo.ModuleName:=ExtractFileName(SysUtils.GetModuleName(HInstance));
  SvrInfo.GUID:=GUIDToString(IModuleInfo);
  SvrInfo.Title:='模块信息接口(IModuleInfo)';
  SvrInfo.Version:='20100512.001';
  SvrInfo.Comments:= '用于获取当前系统加载包的信息及初始化包。';
  Intf.SvcInfo(SvrInfo);

  SvrInfo.GUID:=GUIDToString(IModuleInfo);
  SvrInfo.Title:='模块加载接口(IModuleLoader)';
  SvrInfo.Version:='20110225.001';
  SvrInfo.Comments:= '用户可以用此接口自主加载模块，不用框架默认的从注册表加载方式';
  Intf.SvcInfo(SvrInfo);
end;

constructor TModuleMgr.Create;
begin
  FLoadBatch:='';
  FModuleList := TObjectList.Create(True);

  TIntfFactory.Create(IRegistry,@CreateRegObj);
  TObjFactoryEx.Create([IModuleInfo,IModuleLoader], self);
  TIntfFactory.Create(ISvcInfoEx,@Create_SvcInfoObj);
end;

destructor TModuleMgr.Destroy;
begin
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

procedure TModuleMgr.PluginNotify(Flags: Integer; Intf: IInterface);
var
  i: Integer;
  PluginLoader: TModuleLoader;
begin
  for i := 0 to FModuleList.Count - 1 do
  begin
    PluginLoader := TModuleLoader(FModuleList[i]);

    try
      PluginLoader.ModuleNotify(Flags, Intf);
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

      if Assigned(SplashForm) then
        SplashForm.loading(Format('正在初始化包[%s]',
            [ExtractFileName(PluginLoader.ModuleFileName)]));

      PluginLoader.ModuleInit(self.FLoadBatch);
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

procedure TModuleMgr.LoadBegin;
var BatchID:TGUID;
begin
  if CreateGUID(BatchID)=S_OK then
    self.FLoadBatch:=GUIDToString(BatchID);
end;

procedure TModuleMgr.LoadFinish;
begin
  self.Init;
end;

procedure TModuleMgr.LoadModulesFromDir(const Dir: String);
var DR: TSearchRec;
    ZR: Integer;
    TmpPath,FileExt,FullFileName:String;
begin
  if Dir='' then
    TmpPath:=ExtractFilePath(ParamStr(0))
  else begin
    if RightStr(Dir,1)='\' then
      TmpPath:=Dir
    else tmpPath:=Dir+'\';
  end;
  ZR:=SysUtils.FindFirst(TmpPath+ '*.*', FaAnyfile, DR);
  try
    while ZR = 0 do
    begin
      if ((DR.Attr and FaDirectory <> FaDirectory)
         and (DR.Attr and FaVolumeID <> FaVolumeID))
         and (DR.Name <> '.') and (DR.Name <> '..') then
      begin
        FullFileName:=tmpPath+DR.Name;
        FileExt:=ExtractFileExt(FullFileName);

        if SameText(FileExt,'.dll') or
           SameText(FileExt,'.bpl') then
          self.LoadModuleFromFile(FullFileName);
      end;
      ZR := SysUtils.FindNext(DR);
    end;//end while
  finally
    SysUtils.FindClose(DR);
  end;
end;

procedure TModuleMgr.LoadModuleFromFile(const ModuleFile: string);
begin
  try
    FModuleList.Add(TModuleLoader.Create(ModuleFile,self.FLoadBatch));
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
    try
      ModuleLoader.ModuleFinal;
    Except
      //处理...
    end;
  end;

  //释放工厂里的对象实例
  FactoryManager.ReleaseInstances;
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
