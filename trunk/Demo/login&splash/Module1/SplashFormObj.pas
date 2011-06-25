{------------------------------------
  功能说明：实现ISplashForm接口(闪屏窗体接口)
  创建日期：2008.12.07
  作者：WZW
  版权：WZW
-------------------------------------}
unit SplashFormObj;


interface

uses SysUtils,Messages,SplashFormIntf,SplashForm;

Type
  TSplashFormObj=Class(TInterfacedObject,ISplashForm)
  private
    FSplashForm:Tfrm_Splash;
  protected
    {ISplashForm}
    procedure Show;
    procedure loading(const msg:String);
    function GetWaitTime:Cardinal;
    procedure Hide;
  public
    constructor Create;
    destructor Destroy;override;
  End;

implementation

uses SysFactory;

{ TSplashFormObj }

constructor TSplashFormObj.Create;
begin
  FSplashForm:=Tfrm_Splash.Create(nil);
end;

destructor TSplashFormObj.Destroy;
begin
  FSplashForm.Free;
  inherited;
end;

function TSplashFormObj.GetWaitTime: Cardinal;
begin
  Result:=0;
end;

procedure TSplashFormObj.Hide;
begin
  FSplashForm.Hide;
end;

procedure TSplashFormObj.Show;
begin
  FSplashForm.Show;
end;

procedure TSplashFormObj.loading(const msg: String);
begin
  FSplashForm.mm_Loading.Lines.Add('  '+msg);
  FSplashForm.Refresh;
end;

procedure Create_SplashFormObj(out anInstance: IInterface);
begin
  anInstance:=TSplashFormObj.Create;
end;

initialization
  TIntfFactory.Create(ISplashForm,@Create_SplashFormObj);
finalization

end.

