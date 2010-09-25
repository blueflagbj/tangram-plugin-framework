unit TestObj;

interface

uses Classes,SysUtils,TestIntf,Forms,MDIForm,SvcInfoIntf;

Type
  TtestObj=Class(TInterfacedObject,ITest,ISvcInfo)
  private
  protected
  {ITest}
    procedure Test;
  {ISvrInfo}
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;

  public
    Destructor Destroy;override;
  End;

implementation

Uses SysFactory,SysFactoryEx,MainFormIntf,SysSvc; //_Sys
{ TtestObj }

destructor TtestObj.Destroy;
begin

  inherited;
end;

function TtestObj.GetComments: String;
begin
  Result:='测试接口，测试用的，在test.bpl包里实现。具体请看test包的TestObj单元';
end;

function TtestObj.GetModuleName: String;
begin
  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TtestObj.GetTitle: String;
begin
  Result:='测试接口(ITest)';
end;

function TtestObj.GetVersion: String;
begin
  Result:='20100421.001';
end;

procedure TtestObj.Test;
begin
 // sys.Form.CreateForm(TfrmMDI);
  (SysService as IFormMgr).CreateForm(TfrmMDI);
end;

procedure CreateTestObject(out anInstance: IInterface);
begin
  anInstance:=TtestObj.Create;
end;

initialization
  TSingletonFactory.Create(ITest,@CreateTestObject);

finalization

end.
