unit uExptConst;

interface

uses  Classes, SysUtils,Controls, Windows,ToolsApi;

const
  PageName='Tangram FrameWork';
  Author='wei';
  
function GetFirstModuleSupporting(const IID: TGUID): IOTAModule;

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
end.
