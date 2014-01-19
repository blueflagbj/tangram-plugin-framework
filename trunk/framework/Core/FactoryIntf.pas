{------------------------------------
  功能说明：工厂接口
  创建日期：2010/03/29
  作者：WZW
  版权：WZW
-------------------------------------}
unit FactoryIntf;
//{$weakpackageunit on}

interface

uses uIntfObj,ObjRefIntf;

Type
  TIntfCreatorFunc = function(param:Integer):TObject;

  IEnumKey=Interface
    ['{BCF06768-CF57-41C8-AC40-C17135A80089}']
    procedure EnumKey(const IntfName:String);
  End;

  TFactory=Class(TIntfObj)
  private

  protected
    FParam:Integer;

    function GetObj(out Obj:TObject;out AutoFree:Boolean):Boolean;virtual;
  public
    //Constructor Create;
    //Destructor Destroy;override;

    function GetIntf(const IID: TGUID; out Obj):HResult;virtual;abstract;
    procedure ReleaseIntf;virtual;abstract;

    function Supports(const IntfName:string):Boolean;virtual;abstract;
    procedure EnumKeys(Intf:IEnumKey); virtual;abstract;

    function GetObjRef:IObjRef;dynamic;

    procedure prepare(param:Integer);
  end;

  ///////////////////////////////////////////

  TObjRef=Class(TInterfacedObject,IObjRef)
  private
    FObj:TObject;
    FAutoFree:Boolean;
  protected
    {IObjRef}
    function Obj:TObject;
    function ObjIsNil:Boolean;
  public
    constructor Create(Obj:TObject;AutoFree:Boolean=True);
    destructor Destroy;override;
  End;

implementation

{ TObjRef }

constructor TObjRef.Create(Obj: TObject; AutoFree: Boolean);
begin
  FAutoFree:=AutoFree;
  FObj:=Obj;
end;

destructor TObjRef.Destroy;
begin
  if FAutoFree and (Obj<>nil) then
    Obj.Free;
  inherited;
end;

function TObjRef.Obj: TObject;
begin
  Result:=FObj;
end;

function TObjRef.ObjIsNil: Boolean;
begin
  Result:=FObj=nil;
end;

{ TFactory }

function TFactory.GetObj(out Obj: TObject; out AutoFree: Boolean): Boolean;
begin
  Result:=False;
end;

function TFactory.GetObjRef: IObjRef;
var autoFree:Boolean;
    obj:TObject;
begin
  Result:=nil;
  if self.GetObj(obj,autoFree) then
    Result:=TObjRef.Create(obj,autoFree)
  else Result:=TObjRef.Create(nil,autoFree);
end;

procedure TFactory.prepare(param: Integer);
begin
  Fparam:=param;
end;

end.
