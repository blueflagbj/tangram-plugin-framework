{------------------------------------
  功能说明：接口实现专家
  创建日期：2010.05.08
  作者：WZW
  版权：WZW
-------------------------------------}
unit uImpIntfExpt;

interface
uses
  Classes, SysUtils,Controls, Windows,ToolsApi;
Type
  TImpIntfExpt = class(TInterfacedObject,IOTAWizard,IOTARepositoryWizard,
    IOTAProjectWizard,IOTACreator,IOTAModuleCreator)
  private
   FFileName:String;
   FIntfInfoEnable:Boolean;
   FIntfClass,FIntfFactory,FIntfTitle,FIntfVer,FIntfComments:String;
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

procedure RegImpIntfExpt;

implementation

uses uExptConst,uNewImpIntfUnit;


procedure RegImpIntfExpt;
begin
  RegisterPackageWizard(TImpIntfExpt.Create);
end;
{ TImpIntfExpt }

procedure TImpIntfExpt.AfterSave;
begin

end;

procedure TImpIntfExpt.BeforeSave;
begin

end;

procedure TImpIntfExpt.Destroyed;
begin

end;

procedure TImpIntfExpt.Execute;
var tmpUnitName,tmpClassName:String;
begin
  FrmNewImptUntfUnit:=TFrmNewImptUntfUnit.Create(nil);
  try
    FrmNewImptUntfUnit.EnableIntfInfo:=False;
    if FrmNewImptUntfUnit.ShowModal=mrOK then
    begin
       FIntfInfoEnable:=FrmNewImptUntfUnit.EnableIntfInfo;
       FIntfClass     :=FrmNewImptUntfUnit.edt_className.Text;
       FIntfFactory   :=FrmNewImptUntfUnit.cb_Factory.Text;
       FIntfTitle     :=FrmNewImptUntfUnit.Edt_IntfName.Text;
       FIntfVer       :=FrmNewImptUntfUnit.edt_IntfVer.Text;
       FIntfComments  :=FrmNewImptUntfUnit.mm_IntfComments.Text;

      (BorlandIDEServices as IOTAModuleServices).GetNewModuleAndClassName('Unit',tmpUnitName,tmpClassName,FFileName);
      (BorlandIDEServices as IOTAModuleServices).CreateModule(self);
    end;
  finally
    FrmNewImptUntfUnit.Free;
  end;
end;

procedure TImpIntfExpt.FormCreated(const FormEditor: IOTAFormEditor);
begin

end;

function TImpIntfExpt.GetAncestorName: string;
begin
  Result:='';
end;

function TImpIntfExpt.GetAuthor: string;
begin
  Result:=Author;
end;

function TImpIntfExpt.GetComment: string;
begin
  Result:='接口实现单元向导';
end;

function TImpIntfExpt.GetCreatorType: string;
begin
  Result:=sUnit;
end;

function TImpIntfExpt.GetExisting: Boolean;
begin
  Result:=False;
end;

function TImpIntfExpt.GetFileSystem: string;
begin
  Result:='';
end;

function TImpIntfExpt.GetFormName: string;
begin
  Result:='';
end;

function TImpIntfExpt.GetGlyph: Cardinal;
begin
  Result:=LoadIcon(HInstance,'I');
end;

function TImpIntfExpt.GetIDString: string;
begin
  Result:='{18906EC9-6A84-4422-B738-7B7F929EE83B}';
end;

function TImpIntfExpt.GetImplFileName: string;
begin
  Result:=FFileName;//GetCurrentDir+'\Unit1.pas';
end;

function TImpIntfExpt.GetIntfFileName: string;
begin
  Result:='';
end;

function TImpIntfExpt.GetMainForm: Boolean;
begin
  Result:=False;
end;

function TImpIntfExpt.GetName: string;
begin
  Result:='接口实现单元';
end;

function TImpIntfExpt.GetOwner: IOTAModule;
begin
  Result:=ToolsAPI.GetActiveProject;
  if (Result = nil) then
    Result := GetFirstModuleSupporting(IOTAProject) as IOTAModule;
end;

function TImpIntfExpt.GetPage: string;
begin
  Result:=PageName;
end;

function TImpIntfExpt.GetShowForm: Boolean;
begin
  Result:=False;
end;

function TImpIntfExpt.GetShowSource: Boolean;
begin
  Result:=True;
end;

function TImpIntfExpt.GetState: TWizardState;
begin
  Result:=[wsEnabled];
end;

function TImpIntfExpt.GetUnnamed: Boolean;
begin
  Result:=True;
end;

procedure TImpIntfExpt.Modified;
begin

end;

function TImpIntfExpt.NewFormFile(const FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  Result:=nil;
end;

function IfThen(b:Boolean;const thenStr,ElseStr:String):String;
begin
  if b then
    Result:=thenStr
  else Result:=ElseStr;
end;

function TImpIntfExpt.NewImplSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
var s:String;
begin
  s:='unit '+ModuleIdent+';'+#13#10
    +#13#10
    +'interface'+#13#10
    +#13#10
    +'uses sysUtils,Classes,SysFactory'+ifThen(FintfInfoEnable,',SvcInfoIntf','')
    +';//记得这里引用你的接口单元'+#13#10
    +#13#10
    +'Type'+#13#10
    +'  T'+FIntfClass+'=Class(TInterfacedObject,IXXX'+IfThen(FIntfInfoEnable,',ISvcInfo','')
    +')//假设你的接口叫IXXX(以下同)'+#13#10
    +'  private'+#13#10
    +'  protected'+#13#10;

  if FIntfInfoEnable then
  begin
    s:=s+'  {ISvcInfo}'+#13#10
      +'    function GetModuleName:String;'+#13#10
      +'    function GetTitle:String;'+#13#10
      +'    function GetVersion:String;'+#13#10
      +'    function GetComments:String;'+#13#10;
  end;
  s:=s+'  {IXXX}'+#13#10
    +'    //这里加上你接口方法,然后按Ctrl+Shift+C，实现你的接口...'+#13#10
    +'  Public'+#13#10
    +'  End;'+#13#10
    +#13#10
    +'implementation'+#13#10
    +#13#10
    +'procedure Create_'+FIntfClass+'(out anInstance: IInterface);'+#13#10
    +'begin'+#13#10
    +'  anInstance:=T'+FIntfClass+'.Create;'+#13#10
    +'end;'+#13#10
    +#13#10;
  if FIntfInfoEnable then
  begin
    s:=s+'{ T'+FIntfClass+' }'+#13#10
      +#13#10
      +'function T'+FIntfClass+'.GetComments: String;'+#13#10
      +'begin'+#13#10
      +'  Result:='+QuotedStr(FIntfComments)+';'+#13#10
      +'end;'+#13#10
      +#13#10
      +'function T'+FIntfClass+'.GetModuleName: String;'+#13#10
      +'begin'+#13#10
      +'  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));'+#13#10
      +'end;'+#13#10
      +#13#10
      +'function T'+FIntfClass+'.GetTitle: String;'+#13#10
      +'begin'+#13#10
      +'  Result:='+QuotedStr(FIntfTitle)+';'+#13#10
      +'end;'+#13#10
      +#13#10
      +'function T'+FIntfClass+'.GetVersion: String;'+#13#10
      +'begin'+#13#10
      +'  Result:='+QuotedStr(FIntfVer)+';'+#13#10
      +'end;'+#13#10;
  end;
  s:=s+#13#10
      +'var Factory:TObject;'+#13#10
      +'initialization'+#13#10
      +'  Factory:='+FIntfFactory+'.Create(IXXX,@Create_'+FIntfClass+');'+#13#10
      +'finalization'+#13#10
      +'  Factory.Free;'+#13#10
      +'end.';
  Result:=StringToIOTAFile(S);
end;

function TImpIntfExpt.NewIntfSource(const ModuleIdent, FormIdent,
  AncestorIdent: string): IOTAFile;
begin
  Result:=nil;
end;

end.
