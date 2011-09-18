unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,uIntf, StdCtrls;

type
  TFrmMain = class(TForm,IIntf1)
    Button1: TButton;
    Label1: TLabel;
    Button2: TButton;
    Label2: TLabel;
    StaticText1: TStaticText;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    {IIntf1}
    procedure SetMainFormCaption(const str:String);
    procedure SetMainFormColor(aColor:TColor);
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation 

uses SysSvc,SysFactory,regintf,ObjRefIntf;

{$R *.dfm}

{ TFrmMain }

procedure TFrmMain.Button1Click(Sender: TObject);
var Intf:IIntf2;
begin
  Intf:=SysService as IIntf2; //获取IIntf2接口,IIntf2是DLL模块里实现的
  Intf.ShowDLlForm;
end;

procedure TFrmMain.Button2Click(Sender: TObject);
var Intf:IIntf3;
begin
  Intf:=SysService as IIntf3; //获取IIntf3接口,IIntf3接口是在BPL包里实现的
  Intf.ShowBPLform;
end;

procedure TFrmMain.Button3Click(Sender: TObject);
var objRef:IObjRef;
begin
  objRef:=SysService(100).GetObjRef(IRegistry);
  showmessage(objRef.Obj.ClassName);
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  //注意：这里注册主窗体实现的IIntf1接口，这样其他模块才能使用
  TObjFactory.Create(IIntf1,self);
end;

procedure TFrmMain.SetMainFormCaption(const str: String);
begin
  self.Caption:=str;
end;

procedure TFrmMain.SetMainFormColor(aColor: TColor);
begin
  self.Color:=aColor;
end;

end.