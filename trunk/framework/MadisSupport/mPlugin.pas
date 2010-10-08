unit mPlugin;

interface

uses PluginBase,MainFormIntf,SysFactoryEx,uDM;

Type
  TmPlugin=Class(TPlugin)
  private
    dm:Tdm;
    procedure SortCutClick(pIntf:IShortCutClick);
  public
    Constructor Create(Intf: IInterface); override;
    Destructor Destroy; override;

    procedure Init; override;
    procedure final; override;
    procedure Register(Flags: Integer; Intf: IInterface); override;
  End;

implementation

uses uFrame,DBIntf,InvokeServerIntf;

{ TTest2Menu }

constructor TmPlugin.Create(Intf: IInterface);
begin
  (Intf as IMainForm).RegShortCut('Midas远程方法调用',self.SortCutClick);

  dm:=Tdm.Create(nil);
  TObjFactoryEx.Create([IDBConnection,IDBAccess,IInvokeServer],dm);
end;

destructor TmPlugin.Destroy;
begin
  dm.Free;
  inherited;
end;

procedure TmPlugin.final;
begin
  inherited;

end;

procedure TmPlugin.Init;
begin
  inherited;

end;

procedure TmPlugin.Register(Flags: Integer; Intf: IInterface);
begin
  inherited;

end;

procedure TmPlugin.SortCutClick(pIntf: IShortCutClick);
begin
  pIntf.RegPanel(TFrame4);
end;

end.
 