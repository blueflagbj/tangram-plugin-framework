{ ------------------------------------
  功能说明：TModule祖先类
  创建日期：2010/07/16
  作者：wzw
  版权：wzw
  ------------------------------------- }
unit SysModule;

interface

uses uIntfObj,RegIntf;

Type
  TModuleClass = Class of TModule;

  TModule = Class(TIntfObj)
  private

  protected

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

{ TModule }

constructor TModule.Create;
begin

end;

destructor TModule.Destroy;
begin

  inherited;
end;

procedure TModule.Init;
begin

end;

procedure TModule.final;
begin

end;

procedure TModule.Notify(Flags: Integer; Intf: IInterface);
begin

end;

class procedure TModule.RegisterModule(Reg: IRegistry);
begin

end;

class procedure TModule.UnRegisterModule(Reg: IRegistry);
begin

end;

end.
