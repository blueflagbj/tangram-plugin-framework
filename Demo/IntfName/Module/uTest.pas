unit uTest;

interface

uses sysUtils,Classes,Forms,FactoryIntf,SysFactory,ShowFormIntf;

type
  TShowForm=class(TInterfacedObject,IShowForm)
  private
    FFormClass:TFormClass;
  public
    procedure show;
    constructor Create(FormClass:TFormClass);
    destructor Destroy;override;
  end;
implementation

uses Unit1,Unit2;

{ TShowForm }

constructor TShowForm.Create(FormClass: TFormClass);
begin
  self.FFormClass:=FormClass;
end;

destructor TShowForm.Destroy;
begin

  inherited;
end;

procedure TShowForm.show;
var form:TForm;
begin
  form:=self.FFormClass.Create(nil);
  form.ShowModal;
  form.Free;
end;

function Create_Intf1(param:Integer):TObject;
begin
  result:=TShowForm.Create(TForm1);
end;

function Create_Intf2(param:Integer):TObject;
begin
  result:=TShowForm.Create(TForm2);
end;

initialization
  TIntfFactory.Create('Form1',@Create_Intf1);
  TIntfFactory.Create('Form2',@Create_Intf2);
finalization

end.