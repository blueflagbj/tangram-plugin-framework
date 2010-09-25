unit uReg;

interface

procedure Register;

implementation

uses uNewPackageExpt,uImpIntfExpt,uNewFormExpt,uContainPackageWiz;

procedure Register;
begin
  RegNewPackageExpt;
  RegImpIntfExpt;
  RegNewFormExpt;
  RegContainPackageWiz
end;

end.
