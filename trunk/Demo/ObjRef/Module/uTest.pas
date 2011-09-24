unit uTest;

interface

uses sysUtils,Classes,SysFactory,TestIntf;

implementation

uses Unit1,Unit2;

function Create_Test(param:Integer):TObject;
begin
  Result:=nil;
  case param of
    1:Result:=TForm1.Create(nil);
    2:Result:=TForm2.Create(nil);
  end;
end;


var Factory:TObject;
initialization
  Factory:=TIntfFactory.Create(ITest,@Create_Test);
finalization
  Factory.Free;
end.