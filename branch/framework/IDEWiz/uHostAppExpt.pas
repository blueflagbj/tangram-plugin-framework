{ ------------------------------------
  功能说明：主程序(Host)创建向导
  创建日期：2011.01.29
  作者：WZW
  版权：WZW
  ------------------------------------- }
unit uHostAppExpt;

interface

uses
  Classes, SysUtils, Windows, ToolsApi;

Type
  TNewHostExpt = class(TInterfacedObject, IOTAWizard, IOTARepositoryWizard,
    IOTAProjectWizard, IOTACreator, IOTAProjectCreator, IOTAProjectCreator50,
    IOTAProjectCreator80) //
  private
  public
    constructor Create;
    destructor Destroy; override;
    { IOTARepositoryWizard }
    function GetAuthor: string;
    function GetComment: string;
    function GetPage: string;
    function GetGlyph: Cardinal;
    { IOTAWizard }
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
    { IOTANotifier }
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;

    { IOTACreator }
    function GetCreatorType: string;
    function GetExisting: Boolean;
    function GetFileSystem: string;
    function GetOwner: IOTAModule;
    function GetUnnamed: Boolean;
    { IOTAProjectCreator }
    function GetFileName: string;
    { Return the option file name (C++ .bpr, .bpk, etc...) }
    function GetOptionFileName: string;
    { Return True to show the source }
    function GetShowSource: Boolean;
    { Called to create a new default module for this project }
    procedure NewDefaultModule;
    { Create and return the project option source. (C++) }
    function NewOptionSource(const ProjectName: string): IOTAFile;
    { Called to indicate when to create/modify the project resource file }
    procedure NewProjectResource(const Project: IOTAProject);
    { Create and return the Project source file }
    function NewProjectSource(const ProjectName: string): IOTAFile;
    { IOTAProjectCreator50 }
    { Called to create a new default module(s) for the given project.  This
      interface method is the preferred mechanism. }
    procedure NewDefaultProjectModule(const Project: IOTAProject);
    {IOTAProjectCreator80}
    function GetProjectPersonality: string;
  end;

  THostExportModule = Class(TInterfacedObject, IOTACreator, IOTAModuleCreator)
  private
  protected
    { IOTACreator }
    function GetCreatorType: string;
    function GetExisting: Boolean;
    function GetFileSystem: string;
    function GetOwner: IOTAModule;
    function GetUnnamed: Boolean;
    function GetAncestorName: string;
    { IOTAModuleCreator }
    { Return the implementation filename, or blank to have the IDE create a new
      unique one. (C++ .cpp file or Delphi unit) NOTE: If a value is returned then it *must* be a
      fully qualified filename.  This also applies to GetIntfFileName and
      GetAdditionalFileName on the IOTAAdditionalFilesModuleCreator interface. }
    function GetImplFileName: string;
    { Return the interface filename, or blank to have the IDE create a new
      unique one.  (C++ header) }
    function GetIntfFileName: string;
    { Return the form name }
    function GetFormName: string;
    { Return True to Make this module the main form of the given Owner/Project }
    function GetMainForm: Boolean;
    { Return True to show the form }
    function GetShowForm: Boolean;
    { Return True to show the source }
    function GetShowSource: Boolean;
    { Create and return the Form resource for this new module if applicable }
    function NewFormFile(const FormIdent, AncestorIdent: string): IOTAFile;
    { Create and return the Implementation source for this module. (C++ .cpp
      file or Delphi unit) }
    function NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: string)
      : IOTAFile;
    { Create and return the Interface (C++ header) source for this module }
    function NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: string)
      : IOTAFile;
    { Called when the new form/datamodule/custom module is created }
    procedure FormCreated(const FormEditor: IOTAFormEditor);
  public

  end;

procedure RegNewHostExpt;

implementation

uses uExptConst;

const
  HostName     = 'NewHostApp.dpr';
  MainFormName ='FrmMain';//主窗体名称

procedure RegNewHostExpt;
begin
  RegisterPackageWizard(TNewHostExpt.Create as IOTAWizard);
end;

{ TNewHostExpt }

procedure TNewHostExpt.AfterSave;
begin

end;

procedure TNewHostExpt.BeforeSave;
begin

end;

constructor TNewHostExpt.Create;
begin

end;

destructor TNewHostExpt.Destroy;
begin

  inherited;
end;

procedure TNewHostExpt.Destroyed;
begin

end;

procedure TNewHostExpt.Execute;
begin
 (BorlandIDEServices as IOTAModuleServices).CreateModule(self);
end;

function TNewHostExpt.GetAuthor: string;
begin
  Result := Author;
end;

function TNewHostExpt.GetComment: string;
begin
  Result := '主程序(Host)向导';
end;

function TNewHostExpt.GetCreatorType: string;
begin
  Result := sApplication;
end;

function TNewHostExpt.GetExisting: Boolean;
begin
  Result := False;
end;

function TNewHostExpt.GetFileName: string;
begin
  Result := GetCurrentDir + '\' + HostName;
end;

function TNewHostExpt.GetFileSystem: string;
begin
  Result := '';
end;

function TNewHostExpt.GetGlyph: Cardinal;
begin
  Result := LoadIcon(HInstance, 'F'); // 加载图标
end;

function TNewHostExpt.GetIDString: string;
begin
  Result := '{43E321C2-649B-4FF3-92F0-0A51D4DD8970}';
end;

function TNewHostExpt.GetName: string;
begin
  Result := '主程序(Host)';
end;

function TNewHostExpt.GetOptionFileName: string;
begin
  Result := '';
end;

function TNewHostExpt.GetOwner: IOTAModule;
var
  IModuleServices: IOTAModuleServices;
  IModule: IOTAModule;
  IProjectGroup: IOTAProjectGroup;
  i: Integer;
begin
  Result := nil;
  IModuleServices := BorlandIDEServices as IOTAModuleServices;
  for i := 0 to IModuleServices.ModuleCount - 1 do
  begin
    IModule := IModuleServices.Modules[i];
    if IModule.QueryInterface(IOTAProjectGroup, IProjectGroup) = S_OK then
    begin
      Result := IProjectGroup;
      Break;
    end;
  end;
end;

function TNewHostExpt.GetPage: string;
begin
  Result := PageName;
end;

function TNewHostExpt.GetProjectPersonality: string;
begin
  Result:= sDelphiPersonality;
end;

function TNewHostExpt.GetShowSource: Boolean;
begin
  Result := True;
end;

function TNewHostExpt.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

function TNewHostExpt.GetUnnamed: Boolean;
begin
  Result := True;
end;

procedure TNewHostExpt.Modified;
begin

end;

procedure TNewHostExpt.NewDefaultModule;
begin
  (BorlandIDEServices as IOTAModuleServices).CreateModule(THostExportModule.Create);
end;

procedure TNewHostExpt.NewDefaultProjectModule(const Project: IOTAProject);
begin

end;

function TNewHostExpt.NewOptionSource(const ProjectName: string): IOTAFile;
begin

end;

procedure TNewHostExpt.NewProjectResource(const Project: IOTAProject);
begin
 (Project.ProjectOptions as IOTAProjectOptionsConfigurations)
  .BaseConfiguration.AsBoolean['UsePackages'] := True;
 (Project.ProjectOptions as IOTAProjectOptionsConfigurations)
  .BaseConfiguration.Value['DCC_UsePackage'] := 'vcl;rtl;Tangram_Core;';
end;

function TNewHostExpt.NewProjectSource(const ProjectName: string): IOTAFile;
var
  s: String;
begin
  s := 'Program ' + ProjectName + ';'+ #13#10 + #13#10
    + 'uses' + #13#10
    + 'uTangramFramework;' + #13#10
    + '{$R *.res}' + #13#10 + #13#10
    + 'begin ' + #13#10  //GetFormName
    + '  Application.Initialize;'+#13#10
    + '  Application.MainFormOnTaskbar := True; '+#13#10
    //+ '  Application.CreateForm(T'+MainFormName+','+MainFormName+');'+#13#10 //这句会自动加上...
    + '  Application.Run;'+#13#10
    + 'end.' + #13#10;
  Result := StringToIOTAFile(s);
end;

{ THostExportModule }

procedure THostExportModule.FormCreated(const FormEditor: IOTAFormEditor);
begin

end;

function THostExportModule.GetAncestorName: string;
begin
  Result:='';
end;

function THostExportModule.GetCreatorType: string;
begin
  Result:=sForm;
end;

function THostExportModule.GetExisting: Boolean;
begin
  Result := False;
end;

function THostExportModule.GetFileSystem: string;
begin
  Result := '';
end;

function THostExportModule.GetFormName: string;
begin
  Result:=MainFormName;
end;

function THostExportModule.GetImplFileName: string;
begin
  Result := GetCurrentDir + '\Unit1.pas';
end;

function THostExportModule.GetIntfFileName: string;
begin
  Result := '';
end;

function THostExportModule.GetMainForm: Boolean;
begin
  Result := False;
end;

function THostExportModule.GetOwner: IOTAModule;
begin
  Result := ToolsApi.GetActiveProject;
  if (Result = nil) then
    Result := GetFirstModuleSupporting(IOTAProject) as IOTAProject;
end;

function THostExportModule.GetShowForm: Boolean;
begin
  Result := False;
end;

function THostExportModule.GetShowSource: Boolean;
begin
  Result := True;
end;

function THostExportModule.GetUnnamed: Boolean;
begin
  Result := True;
end;

function THostExportModule.NewFormFile(const FormIdent, AncestorIdent: string)
  : IOTAFile;
begin
  Result := nil;
end;

function THostExportModule.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
var s:String;
begin
  s:='unit '+ModuleIdent+';'+#13#10+#13#10
    +'interface'+#13#10+#13#10
    +'uses'+#13#10
    +'  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,'+#13#10
    +'  Dialogs;'+#13#10+#13#10
    +'type'+#13#10
    +'  T'+FormIdent+' = class(TForm)'+#13#10
    +'  private'+#13#10
    +'    { Private declarations }'+#13#10
    +'  public'+#13#10
    +'    { Public declarations }'+#13#10
    +'  end;'+#13#10+#13#10

    +'var'+#13#10
    +'  '+FormIdent+': T'+FormIdent+';'+#13#10+#13#10
    +'implementation '+#13#10+#13#10
    +'uses SysSvc;'+#13#10+#13#10
    +'{$R *.dfm}'+#13#10+#13#10
    +'end.';
  Result := StringToIOTAFile(s);
end;

function THostExportModule.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  Result:=nil;
end;

end.
