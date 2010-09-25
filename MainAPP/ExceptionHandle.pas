unit ExceptionHandle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, ComCtrls, StdCtrls, Buttons;

type
  Tfrm_Exception = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edt_Exceptionclass: TEdit;
    edt_SourceClass: TEdit;
    mm_ExceptionMsg: TMemo;
    btn_OK: TBitBtn;
    Image1: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    function GetExceptionClass: String;
    procedure SetExceptionClass(const Value: String);
    procedure SetExceptionMsg(const Value: String);
    procedure SetSourceClass(const Value: string);
    function GetSourceClass: string;
    function GetExceptionMsg: String;
    { Private declarations }
  public
    property ExceptionClass:String Read GetExceptionClass Write SetExceptionClass;
    property SourceClass:string Read GetSourceClass Write SetSourceClass;
    property ExceptionMsg:String Read GetExceptionMsg Write SetExceptionMsg;
  end;

var
  frm_Exception: Tfrm_Exception;

implementation

{$R *.dfm}

procedure Tfrm_Exception.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure Tfrm_Exception.FormShow(Sender: TObject);
begin
  MessageBeep(16);
end;

function Tfrm_Exception.GetExceptionClass: String;
begin
  Result:=self.edt_Exceptionclass.Text;
end;

function Tfrm_Exception.GetExceptionMsg: String;
begin
  Result:=mm_ExceptionMsg.Text;
end;

function Tfrm_Exception.GetSourceClass: string;
begin
  Result:=edt_Sourceclass.Text;
end;

procedure Tfrm_Exception.SetExceptionClass(const Value: String);
begin
  edt_ExceptionClass.Text:=Value;
end;

procedure Tfrm_Exception.SetExceptionMsg(const Value: String);
begin
  mm_ExceptionMsg.text:=Value;
end;

procedure Tfrm_Exception.SetSourceClass(const Value: string);
begin
  edt_SourceClass.text:=Value;
end;

end.
