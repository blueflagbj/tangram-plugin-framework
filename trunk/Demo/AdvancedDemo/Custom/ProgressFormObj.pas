{------------------------------------
  功能说明：实现IProgressForm 接口(等待窗口)
  创建日期：2008.12.12
  作者：WZW
  版权：WZW
-------------------------------------}
unit ProgressFormObj;

interface

uses SysUtils,Forms,ProgressFormIntf,ProgressForm,_sys,MainFormIntf,SvcInfoIntf;

Type
  TProgressFormObj=Class(TInterfacedObject,IProgressForm,ISvcInfo)
  private
    FProgressForm:Tfrm_ProgressForm;
    //FMainFormIntf:IMainForm;
    procedure CreateForm;
  protected
    {IProgressForm}
    procedure ShowMsg(const MsgStr:String);
    procedure progress(const Max,Position:Integer);
    procedure Hide;
    {ISvcInfo}
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;
  public
    constructor Create;
    destructor Destroy;override;
  End;

implementation

uses SysFactory;

{ TProgressFormObj }

constructor TProgressFormObj.Create;
//var err:string;
begin
  FProgressForm:=nil;
  //取得IMainForm接口
  //sys.GetSpecifyIntf(IMainForm,FMainFormIntf,err);
end;

procedure TProgressFormObj.CreateForm;
begin
  if FProgressForm=nil then
  begin
    FProgressForm:=Tfrm_ProgressForm.Create(nil);
    //FMainFormIntf.DisableExit;//不允许退出程序
  end;
  FProgressForm.Show;
end;

destructor TProgressFormObj.Destroy;
begin
  if assigned(FProgressForm) then
    FProgressForm.Free;
  inherited;
end;

function TProgressFormObj.GetComments: String;
begin
  Result:='做长时间操作时可以通过本接口显示一个等待窗口。';
end;

function TProgressFormObj.GetModuleName: String;
begin
  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TProgressFormObj.GetTitle: String;
begin
  Result:='进度窗接口(IProgressForm)';
end;

function TProgressFormObj.GetVersion: String;
begin
  Result:='20100421.001';
end;

procedure TProgressFormObj.Hide;
begin
  if assigned(FProgressForm) then
  begin
    //FMainFormIntf.EnableExit;//允许退出程序
    FProgressForm.Hide;
    FProgressForm.Free;
    FProgressForm:=nil;
  end;
end;

procedure TProgressFormObj.progress(const Max, Position: Integer);
begin
  CreateForm;
  FProgressForm.ProgressBar.Visible:=True;
  FProgressForm.ProgressBar.Max:=Max;
  FProgressForm.ProgressBar.Position:=Position;
  //application.ProcessMessages;
end;

procedure TProgressFormObj.ShowMsg(const MsgStr: String);
begin
  CreateForm;
  FProgressForm.pal_Msg.Caption:=MsgStr;
  //FProgressForm.pal_Msg.Repaint;
  application.ProcessMessages;
end;

function Create_ProgressFormObj(param:Integer):TObject;
begin
  Result:=TProgressFormObj.Create;
end;

initialization
  TIntfFactory.Create(IProgressForm,@Create_ProgressFormObj);
finalization

end.

