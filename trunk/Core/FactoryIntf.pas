{------------------------------------
  功能说明：工厂接口
  创建日期：2010/03/29
  作者：WZW
  版权：WZW
-------------------------------------}
unit FactoryIntf;
//{$weakpackageunit on}

interface

Type
  ISysFactory=Interface
  ['{1E82A603-712A-4FBB-8323-95AAD6736F15}']
    procedure CreateInstance(const IID : TGUID; out Obj);
    procedure ReleaseInstance;
    function Supports(IID:TGUID):Boolean;
  end;
implementation

end.
