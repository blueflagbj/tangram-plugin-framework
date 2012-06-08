unit uExptConst;

interface

uses  Classes, SysUtils,Controls, Windows,ToolsApi;

const
  PageName='Tangram FrameWork';
  Author='wei';
  
function GetFirstModuleSupporting(const IID: TGUID): IOTAModule;
function GetTModuleObjCode(const ModuleIdent,ClsName:String):String;

implementation

function GetFirstModuleSupporting(const IID: TGUID): IOTAModule;
var
  ModuleServices: IOTAModuleServices;
  i: integer;
begin
  Result := nil;
  if Assigned(BorlandIDEServices) then
  begin
    // look for the first project
    ModuleServices := BorlandIDEServices as IOTAModuleServices;
    for i := 0 to ModuleServices.ModuleCount - 1 do
      if Supports(ModuleServices.Modules[i], IID, Result) then
        Break;
  end;
end;

function GetTModuleObjCode(const ModuleIdent,ClsName:String):String;
var
  s: String;
begin
  s:='unit '+ModuleIdent+';'+#13#10+#13#10
    +'interface'+#13#10+#13#10
    +'uses SysUtils,Classes,uTangramModule,SysModule,RegIntf;'+#13#10+#13#10
    +'Type'+#13#10
    +'  '+ClsName+'=Class(TModule)'+#13#10
    +'  private '+#13#10
    +'  public '+#13#10
    +'    Constructor Create; override;'+#13#10
    +'    Destructor Destroy; override;'+#13#10+#13#10
    +'    procedure Init; override;'+#13#10
    +'    procedure final; override;'+#13#10
    +'    procedure Notify(Flags: Integer; Intf: IInterface;Param:Integer); override;'+#13#10+#13#10
    +'    class procedure RegisterModule(Reg:IRegistry);override;'+#13#10
    +'    class procedure UnRegisterModule(Reg:IRegistry);override;'+#13#10
    +'  End;'+#13#10+#13#10
    +'implementation'+#13#10+#13#10
    +'uses SysSvc;'+#13#10+#13#10
    +'const'+#13#10
    +'  InstallKey=''SYSTEM\LOADMODULE\USER'';'+#13#10+#13#10
    +'{ '+ClsName+' }'+#13#10+#13#10
    +'constructor '+ClsName+'.Create;'+#13#10
    +'begin '+#13#10
    +'  inherited;'+#13#10
    +'  //当前模块加载后执行，不要在这里取接口...'+#13#10
    +'end;'+#13#10+#13#10
    +'destructor '+ClsName+'.Destroy;'+#13#10
    +'begin'+#13#10
    +'  //当前模块卸载前执行，不要在这里取接口...'+#13#10
    +'  inherited;'+#13#10
    +'end;'+#13#10+#13#10
    +'procedure '+ClsName+'.Init;'+#13#10
    +'begin'+#13#10
    +'  //初始化，所有模块加载完成后会执行到这里，在这取接口是安全的...'+#13#10
    +'  inherited;'+#13#10
    +'end;'+#13#10+#13#10
    +'procedure '+ClsName+'.final;'+#13#10
    +'begin'+#13#10
    +'  //终始化，卸载模块前会执行到这里，这里取接口是安全的...'+#13#10
    +'  inherited;'+#13#10
    +'end;'+#13#10+#13#10
    +'procedure '+ClsName+'.Notify(Flags: Integer; Intf: IInterface;Param:Integer);'+#13#10
    +'begin'+#13#10
    +'  inherited;'+#13#10+#13#10
    +'end;'+#13#10+#13#10
    +'class procedure '+ClsName+'.RegisterModule(Reg: IRegistry);'+#13#10
    +'begin'+#13#10
    +'  //注册模块'+#13#10
    +'  DefaultRegisterModule(Reg,InstallKey);'+#13#10
    +'end;'+#13#10+#13#10
    +'class procedure '+ClsName+'.UnRegisterModule(Reg: IRegistry);'+#13#10
    +'begin '+#13#10
    +'  //取消注册模块'+#13#10
    +'  DefaultUnRegisterModule(Reg,InstallKey);'+#13#10
    +'end; '+#13#10+#13#10
    +'initialization'+#13#10
    +'  RegisterModuleClass('+ClsName+');'+#13#10
    +'finalization'+#13#10+#13#10
    +'end.'+#13#10;
  Result := s;
end;

end.
