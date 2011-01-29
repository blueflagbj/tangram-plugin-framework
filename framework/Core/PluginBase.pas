{ ------------------------------------
  功能说明：插件类祖先
  创建日期：2010/07/16
  作者：wzw
  版权：wzw
  ------------------------------------- }
unit PluginBase;

interface

uses RegIntf;

Type
  TPluginClass = Class of TPlugin;

  TPlugin = Class(TObject, IInterface)
  private

  protected
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    Constructor Create; virtual;
    Destructor Destroy; override;

    procedure Init; virtual;
    procedure final; virtual;
    procedure Notify(Flags: Integer; Intf: IInterface); virtual;

    class procedure RegisterModule(Reg:IRegistry);virtual;
    class procedure UnRegisterModule(Reg:IRegistry);virtual;
  End;

implementation

{ TPlugIn }

constructor TPlugin.Create;
begin

end;

destructor TPlugin.Destroy;
begin

  inherited;
end;

function TPlugin.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TPlugin._AddRef: Integer;
begin
  Result := -1;
end;

function TPlugin._Release: Integer;
begin
  Result := -1;
end;

procedure TPlugin.Init;
begin

end;

procedure TPlugin.final;
begin

end;

procedure TPlugin.Notify(Flags: Integer; Intf: IInterface);
begin

end;

class procedure TPlugin.RegisterModule(Reg: IRegistry);
begin

end;

class procedure TPlugin.UnRegisterModule(Reg: IRegistry);
begin

end;

end.
