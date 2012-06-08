unit uIntfObj3;

interface

uses sysUtils,Classes,SysFactory,SvcInfoIntf,uIntf;

Type
  TIntfObj3=Class(TInterfacedObject,IIntf3,ISvcInfo)
  private
  protected
  {ISvcInfo}
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;
  {IIntf3}
    procedure ShowBPLform;
  Public
  End;

implementation

uses ufrmBPL;

function Create_IntfObj3(param:Integer):TObject;
begin
  Result:=TIntfObj3.Create;
end;

{ TIntfObj3 }

function TIntfObj3.GetComments: String;
begin
  Result:='测试BPL接口';
end;

function TIntfObj3.GetModuleName: String;
begin
  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TIntfObj3.GetTitle: String;
begin
  Result:='BPL里实现的接口(IIntf3)';
end;

function TIntfObj3.GetVersion: String;
begin
  Result:='20110218.001';
end;

procedure TIntfObj3.ShowBPLform;
begin
  frmBPL:=TfrmBPL.Create(nil);
  try
    frmBPL.ShowModal;
  finally
    frmBPL.Free;
  end;
end;

initialization
  TIntfFactory.Create(IIntf3,Create_IntfObj3);
finalization
end.