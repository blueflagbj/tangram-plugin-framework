unit uReg;

interface

procedure Register;

implementation

uses uNewPackageExpt,uImpIntfExpt,uNewFormExpt,uContainPackageWiz,
     uNewDLLExpt;

procedure Register;
begin
  RegNewDLLExpt;
  RegNewPackageExpt;
  RegImpIntfExpt;
  RegNewFormExpt;
  RegContainPackageWiz
end;

end.
