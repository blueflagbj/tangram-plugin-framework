{ ------------------------------------
  功能说明：DLL模块生成专家
  创建日期：2011.01.25
  作者：WZW
  版权：WZW
  ------------------------------------- }
unit uNewDLLExpt;

interface

uses
  Classes, SysUtils, Windows, ToolsApi;

Type
  TNewDLLExpt = class(TInterfacedObject, IOTAWizard, IOTARepositoryWizard,
    IOTAProjectWizard, IOTACreator, IOTAProjectCreator,IOTAProjectCreator50,
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

  TDLLExportModule = Class(TInterfacedObject, IOTACreator,
    IOTAModuleCreator)
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

procedure RegNewDLLExpt;

implementation

uses uExptConst;

const
  DLLName = 'NewDLL.dpr';

procedure RegNewDLLExpt;
begin
  RegisterPackageWizard(TNewDLLExpt.Create as IOTAWizard);
end;

{ TNewDLLExpt }

procedure TNewDLLExpt.AfterSave;
begin

end;

procedure TNewDLLExpt.BeforeSave;
begin

end;

constructor TNewDLLExpt.Create;
begin

end;

destructor TNewDLLExpt.Destroy;
begin

  inherited;
end;

procedure TNewDLLExpt.Destroyed;
begin

end;

procedure TNewDLLExpt.Execute;
begin
  (BorlandIDEServices as IOTAModuleServices).CreateModule(self);
end;

function TNewDLLExpt.GetAuthor: string;
begin
  Result := Author;
end;

function TNewDLLExpt.GetComment: string;
begin
  Result:='DLL模块向导';
end;

function TNewDLLExpt.GetCreatorType: string;
begin
  Result:=sLibrary;
end;

function TNewDLLExpt.GetExisting: Boolean;
begin
  Result:=False;
end;

function TNewDLLExpt.GetFileName: string;
begin
  Result := GetCurrentDir + '\' + DLLName;
end;

function TNewDLLExpt.GetFileSystem: string;
begin
  Result:='';
end;

function TNewDLLExpt.GetGlyph: Cardinal;
begin
  Result := LoadIcon(HInstance, 'D');//加载图标
end;

function TNewDLLExpt.GetIDString: string;
begin
  Result:='{A25FE721-78C7-4F08-BC0A-EF0BCE393CA1}';
end;

function TNewDLLExpt.GetName: string;
begin
  Result:='DLL模块';
end;

function TNewDLLExpt.GetOptionFileName: string;
begin
  Result:='';
end;

function TNewDLLExpt.GetOwner: IOTAModule;
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

function TNewDLLExpt.GetPage: string;
begin
  Result:=PageName;
end;

function TNewDLLExpt.GetProjectPersonality: string;
begin
  Result:= sDelphiPersonality;
end;

function TNewDLLExpt.GetShowSource: Boolean;
begin
  Result:=True;
end;

function TNewDLLExpt.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

function TNewDLLExpt.GetUnnamed: Boolean;
begin
  Result:=True;
end;

procedure TNewDLLExpt.Modified;
begin

end;

procedure TNewDLLExpt.NewDefaultModule;
begin
  (BorlandIDEServices as IOTAModuleServices).CreateModule(TDLLExportModule.Create);
end;

procedure TNewDLLExpt.NewDefaultProjectModule(const Project: IOTAProject);
begin
  //Project.AddFile('Tangram_Core.dcp', False);
end;

function TNewDLLExpt.NewOptionSource(const ProjectName: string): IOTAFile;
begin
  Result:=nil;
end;

procedure TNewDLLExpt.NewProjectResource(const Project: IOTAProject);
begin
  (Project.ProjectOptions as IOTAProjectOptionsConfigurations).BaseConfiguration.AsBoolean['UsePackages']:=True;
  (Project.ProjectOptions as IOTAProjectOptionsConfigurations).BaseConfiguration.Value['DCC_UsePackage']:='vcl;rtl;Tangram_Core;';
   //D2009以上下面方法不能用了
 // Project.ProjectOptions.Values['UsePackages']:=True;
  //Project.ProjectOptions.Values['Packages']:='rtl;Tangram_Core';
end;

function TNewDLLExpt.NewProjectSource(const ProjectName: string): IOTAFile;
var
  s: String;
begin
  s:='library '+ProjectName+';'+#13#10+#13#10
    +'{$R *.res}'+#13#10+#13#10
    +'begin '+#13#10
    +'end.'+#13#10;
  Result := StringToIOTAFile(s);
end;

{ TDLLExportModule }

procedure TDLLExportModule.FormCreated(const FormEditor: IOTAFormEditor);
begin

end;

function TDLLExportModule.GetAncestorName: string;
begin
  Result:='';
end;

function TDLLExportModule.GetCreatorType: string;
begin
  Result := sUnit;
end;

function TDLLExportModule.GetExisting: Boolean;
begin
  Result := False;
end;

function TDLLExportModule.GetFileSystem: string;
begin
  Result := '';
end;

function TDLLExportModule.GetFormName: string;
begin
  Result := '';
end;

function TDLLExportModule.GetImplFileName: string;
begin
  Result := GetCurrentDir + '\Unit1.pas';
end;

function TDLLExportModule.GetIntfFileName: string;
begin
  Result := '';
end;

function TDLLExportModule.GetMainForm: Boolean;
begin
  Result := False;
end;

function TDLLExportModule.GetOwner: IOTAModule;
begin
  Result := ToolsApi.GetActiveProject;
  if (Result = nil) then
    Result := GetFirstModuleSupporting(IOTAProject) as IOTAProject;
end;


function TDLLExportModule.GetShowForm: Boolean;
begin
  Result := False;
end;

function TDLLExportModule.GetShowSource: Boolean;
begin
  Result := True;
end;

function TDLLExportModule.GetUnnamed: Boolean;
begin
  Result := True;
end;

function TDLLExportModule.NewFormFile(const FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  Result := nil;
end;

function TDLLExportModule.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  Result := StringToIOTAFile(GetTModuleObjCode(ModuleIdent,'TUserModule'));
end;

function TDLLExportModule.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  Result := nil;
end;

end.
