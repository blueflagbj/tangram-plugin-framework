unit uContainPackageWiz;

interface

uses
  Classes, SysUtils, Windows,ToolsApi;
Type
  TContainPackageWiz = class(TInterfacedObject,IOTAWizard,IOTARepositoryWizard,
    IOTAProjectWizard,IOTACreator,IOTAProjectCreator,IOTAProjectCreator50,IOTAProjectCreator80)
  private
    FUnitList:TStrings;
  public
    constructor Create;
    destructor Destroy; override;
    {IOTARepositoryWizard}
    function GetAuthor: string;
    function GetComment: string;
    function GetPage: string;
    function GetGlyph: Cardinal;
    {IOTAWizard}
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
    {IOTANotifier}
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;

    {IOTACreator}
    function GetCreatorType: string;
    function GetExisting: Boolean;
    function GetFileSystem: string;
    function GetOwner: IOTAModule;
    function GetUnnamed: Boolean;
    {IOTAProjectCreator}
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

procedure RegContainPackageWiz;

implementation

uses uExptConst,uSelPackages,Controls;

const PackageName='NewPackage.dpk';

procedure RegContainPackageWiz;
begin
  RegisterPackageWizard(TContainPackageWiz.Create as IOTAWizard);
end;
{ TContainPackageWiz }

procedure TContainPackageWiz.AfterSave;
begin

end;

procedure TContainPackageWiz.BeforeSave;
begin

end;

constructor TContainPackageWiz.Create;
begin
  FUnitList:=TStringList.Create;
end;

destructor TContainPackageWiz.Destroy;
begin
  FUnitList.Free;
  inherited;
end;

procedure TContainPackageWiz.Destroyed;
begin

end;

procedure TContainPackageWiz.Execute;
begin
  frmSelPackages:=TfrmSelPackages.Create(nil);
  try
    FUnitList.Clear;
    if frmSelPackages.ShowModal=mrOK then
    begin
      frmSelPackages.GetUnitList(FUnitList);
      (BorlandIDEServices as IOTAModuleServices).CreateModule(self);
    end;
  finally
    frmSelPackages.Free;
  end;
end;

function TContainPackageWiz.GetAuthor: string;
begin
  Result:=Author;
end;

function TContainPackageWiz.GetComment: string;
begin
  Result:='把多个包合并成一个包';
end;

function TContainPackageWiz.GetCreatorType: string;
begin
  Result:=sPackage;
end;

function TContainPackageWiz.GetExisting: Boolean;
begin
  Result:=False;
end;

function TContainPackageWiz.GetFileName: string;
begin
  Result:=GetCurrentDir+'\'+PackageName;
end;

function TContainPackageWiz.GetFileSystem: string;
begin
  Result:='';
end;

function TContainPackageWiz.GetGlyph: Cardinal;
begin
  Result:=LoadIcon(HInstance,'PKGWIZ');
end;

function TContainPackageWiz.GetIDString: string;
begin
  Result:='{5885C7DB-F6BF-46E2-88C6-34292F38EF20}';
end;

function TContainPackageWiz.GetName: string;
begin
  Result:='包合并向导';
end;

function TContainPackageWiz.GetOptionFileName: string;
begin
  Result:='';
end;

function TContainPackageWiz.GetOwner: IOTAModule;
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

function TContainPackageWiz.GetPage: string;
begin
  Result:=PageName;
end;

function TContainPackageWiz.GetProjectPersonality: string;
begin
  Result:= sDelphiPersonality;
end;

function TContainPackageWiz.GetShowSource: Boolean;
begin
  Result:=True;
end;

function TContainPackageWiz.GetState: TWizardState;
begin
  Result:=[wsEnabled];
end;

function TContainPackageWiz.GetUnnamed: Boolean;
begin
  Result:=True;
end;

procedure TContainPackageWiz.Modified;
begin

end;

procedure TContainPackageWiz.NewDefaultModule;
begin

end;

procedure TContainPackageWiz.NewDefaultProjectModule(
  const Project: IOTAProject);
var i:Integer;
begin
  for i:=0 to FUnitList.Count-1 do
  begin
    Project.AddFile(FUnitList[i]+'.dcu',False);
  end;
end;

function TContainPackageWiz.NewOptionSource(
  const ProjectName: string): IOTAFile;
begin

end;

procedure TContainPackageWiz.NewProjectResource(
  const Project: IOTAProject);
begin

end;

function TContainPackageWiz.NewProjectSource(
  const ProjectName: string): IOTAFile;
var s:String;
begin
  s:='package '+ProjectName+';'+#13#10  
         +#13#10
         +'{$R *.res}'+#13#10
         +'{$ALIGN 8}'+#13#10
         +'{$ASSERTIONS ON}'+#13#10
         +'{$BOOLEVAL OFF}'+#13#10
         +'{$DEBUGINFO ON}'+#13#10
         +'{$EXTENDEDSYNTAX ON}'+#13#10
         +'{$IMPORTEDDATA ON}'+#13#10
         +'{$IOCHECKS ON}'+#13#10
         +'{$LOCALSYMBOLS ON}'+#13#10
         +'{$LONGSTRINGS ON}'+#13#10
         +'{$OPENSTRINGS ON}'+#13#10
         +'{$OPTIMIZATION ON}'+#13#10
         +'{$OVERFLOWCHECKS OFF}'+#13#10
         +'{$RANGECHECKS OFF}'+#13#10
         +'{$REFERENCEINFO ON}'+#13#10
         +'{$SAFEDIVIDE OFF}'+#13#10
         +'{$STACKFRAMES OFF}'+#13#10
         +'{$TYPEDADDRESS OFF}'+#13#10
         +'{$VARSTRINGCHECKS ON}'+#13#10
         +'{$WRITEABLECONST OFF}'+#13#10
         +'{$MINENUMSIZE 1}'+#13#10
         +'{$IMAGEBASE $400000}'+#13#10
         +'{$RUNONLY}'+#13#10
         +'{$IMPLICITBUILD OFF}'+#13#10
         +#13#10
         +'end.';
  Result:=StringToIOTAFile(s);
end;

end.
