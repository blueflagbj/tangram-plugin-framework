{------------------------------------
  功能说明：工厂接口
  创建日期：2010/03/29
  作者：WZW
  版权：WZW
-------------------------------------}
unit FactoryIntf;
//{$weakpackageunit on}

interface

uses uIntfObj;

Type
  IEnumKey=Interface
    ['{BCF06768-CF57-41C8-AC40-C17135A80089}']
    procedure EnumKey(const IIDStr:String);
  End;

  TFactory=Class(TIntfObj)
  private
  protected

  public
    //Constructor Create;
    //Destructor Destroy;override;

    procedure CreateInstance(const IID : TGUID; out Obj);virtual;abstract;
    procedure ReleaseInstance;virtual;abstract;

    function Supports(IID:TGUID):Boolean;virtual;abstract;
    procedure EnumKeys(Intf:IEnumKey); virtual;abstract;
  end;
implementation

{ TFactory }

end.
