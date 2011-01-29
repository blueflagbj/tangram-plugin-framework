unit uReg;

interface

procedure Register;

implementation

uses uNewPackageExpt,uImpIntfExpt,uNewFormExpt,uContainPackageWiz,
     uNewDLLExpt,uHostAppExpt;

procedure Register;
begin
  RegNewHostExpt;
  RegNewDLLExpt;
  RegNewPackageExpt;
  RegImpIntfExpt;
  //RegNewFormExpt;
  RegContainPackageWiz
end;

end.
