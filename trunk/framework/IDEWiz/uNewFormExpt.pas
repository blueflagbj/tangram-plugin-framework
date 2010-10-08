{------------------------------------
  功能说明：窗口生成专家
  创建日期：2010.05.09
  作者：WZW
  版权：WZW
-------------------------------------}
unit uNewFormExpt;

interface
uses
  Classes, SysUtils,Controls, Windows,ToolsApi;

Type
  TNewFormExpt = class(TInterfacedObject,IOTAWizard,IOTARepositoryWizard,
    IOTAProjectWizard,IOTACreator,IOTAModuleCreator)
  private
   FFileName:String;
  protected
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
    function GetAncestorName: string;
    {IOTAModuleCreator}
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
    function NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
    { Create and return the Interface (C++ header) source for this module }
    function NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
    { Called when the new form/datamodule/custom module is created }
    procedure FormCreated(const FormEditor: IOTAFormEditor);
  public
  end;

procedure RegNewFormExpt;

implementation

uses uExptConst;

procedure RegNewFormExpt;
begin
  RegisterPackageWizard(TNewFormExpt.Create as IOTAWizard);
end;

{ TNewFormExpt }

procedure TNewFormExpt.AfterSave;
begin

end;

procedure TNewFormExpt.BeforeSave;
begin

end;

procedure TNewFormExpt.Destroyed;
begin

end;

procedure TNewFormExpt.Execute;
var tmpUnitName,tmpClassName:String;
begin
  (BorlandIDEServices as IOTAModuleServices).GetNewModuleAndClassName('Unit',tmpUnitName,tmpClassName,FFileName);
  (BorlandIDEServices as IOTAModuleServices).CreateModule(self);
end;

procedure TNewFormExpt.FormCreated(const FormEditor: IOTAFormEditor);
begin
  
end;

function TNewFormExpt.GetAncestorName: string;
begin
  Result:='BaseForm';
end;

function TNewFormExpt.GetAuthor: string;
begin
  Result:=Author;
end;

function TNewFormExpt.GetComment: string;
begin
  Result:='窗体生成向导';
end;

function TNewFormExpt.GetCreatorType: string;
begin
  Result:=sForm;
end;

function TNewFormExpt.GetExisting: Boolean;
begin
  Result:=False;
end;

function TNewFormExpt.GetFileSystem: string;
begin
  Result:='';
end;

function TNewFormExpt.GetFormName: string;
begin
  Result:='NewForm1';//这里还点小问题,要自动生成名称。。。
end;

function TNewFormExpt.GetGlyph: Cardinal;
begin
  Result:=LoadIcon(HInstance,'F');
end;

function TNewFormExpt.GetIDString: string;
begin
  Result:='{77B20477-1261-4E61-97A3-DC2821C8E102}';
end;

function TNewFormExpt.GetImplFileName: string;
begin
  Result:=FFileName;
end;

function TNewFormExpt.GetIntfFileName: string;
begin
  Result:='';
end;

function TNewFormExpt.GetMainForm: Boolean;
begin
  Result:=False;
end;

function TNewFormExpt.GetName: string;
begin
  Result:='普通窗体';
end;

function TNewFormExpt.GetOwner: IOTAModule;
begin
  Result:=ToolsAPI.GetActiveProject;
  if (Result = nil) then
    Result := GetFirstModuleSupporting(IOTAProject) as IOTAProject;
end;

function TNewFormExpt.GetPage: string;
begin
  Result:=PageName;
end;

function TNewFormExpt.GetShowForm: Boolean;
begin
  Result:=True;
end;

function TNewFormExpt.GetShowSource: Boolean;
begin
  Result:=True;
end;

function TNewFormExpt.GetState: TWizardState;
begin
  Result:=[wsEnabled];
end;

function TNewFormExpt.GetUnnamed: Boolean;
begin
  Result:=True;
end;

procedure TNewFormExpt.Modified;
begin

end;

function TNewFormExpt.NewFormFile(const FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  //...
end;

function TNewFormExpt.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  //..
end;

function TNewFormExpt.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  Result:=nil;
end;

end.
