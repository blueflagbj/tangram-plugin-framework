{------------------------------------
  功能说明：实现IInterface接口，但不同于TInterfacedObject，
            引用计数为0不会自动释放
  创建日期：2011/04/02
  作者：WZW
  版权：WZW
-------------------------------------}
unit uIntfObj;

interface

Type
  TIntfObj=Class(TObject,IInterface)
  private

  protected
    {IInterface}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
  End;
implementation

{ TIntfObj }

function TIntfObj.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TIntfObj._AddRef: Integer;
begin
  Result:=-1;
end;

function TIntfObj._Release: Integer;
begin
  Result:=-1;
end;

end.
