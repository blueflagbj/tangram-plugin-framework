unit uTestSvr;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Messages, SysUtils, Classes, ComServ, ComObj, VCLCom, DataBkr,
  DBClient, MidServer_TLB, StdVcl, DB, ADODB, Provider;

type
  TDM = class(TRemoteDataModule, ITest)
    dsProvider: TDataSetProvider;
    qry: TADOQuery;
    conn: TADOConnection;
    procedure RemoteDataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  protected
    class procedure UpdateRegistry(Register: Boolean; const ClassID, ProgID: string); override;
    function QryData(const SQL: WideString): OleVariant; safecall;
    function ApplyUpdate(const Tablename: WideString;
      Delta: OleVariant): Shortint; safecall;
    function ExecSQL(const SQL: WideString): Shortint; safecall;
    function GetDateTime: TDateTime; safecall;
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

class procedure TDM.UpdateRegistry(Register: Boolean; const ClassID, ProgID: string);
begin
  if Register then
  begin
    inherited UpdateRegistry(Register, ClassID, ProgID);
    EnableSocketTransport(ClassID);
    EnableWebTransport(ClassID);
  end else
  begin
    DisableSocketTransport(ClassID);
    DisableWebTransport(ClassID);
    inherited UpdateRegistry(Register, ClassID, ProgID);
  end;
end;

function TDM.QryData(const SQL: WideString): OleVariant;
begin
  self.qry.SQL.Text:=SQL;
  try
    self.qry.Open;
    Result:=self.dsProvider.Data;
  Except
  end;
end;

function TDM.ApplyUpdate(const Tablename: WideString;
  Delta: OleVariant): Shortint;
const sql='Select * from %s where 1<>1';
var ErrCount:Integer;
begin
  Result:=1;
  qry.SQL.Text:=Format(sql,[TableName]);
  try
    qry.Open;
    self.dsProvider.ApplyUpdates(Delta,-1,ErrCount);
  Except
    Result:=0;
  end;
end;

function TDM.ExecSQL(const SQL: WideString): Shortint;
begin
  Result:=1;
  qry.SQL.Text:=SQL;
  try
    qry.ExecSQL;
  Except
    Result:=0;
  end;
end;

procedure TDM.RemoteDataModuleCreate(Sender: TObject);
const ConnStr='Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%s;Persist Security Info=False';
begin
  self.conn.ConnectionString:=Format(ConnStr,[ExtractFilePath(ParamStr(0))+'\DB\DB.mdb']);
  try
    conn.Connected:=True;
  Except
    on E:Exception do
      MessageBox(0,pchar('连接数据库失败：'+E.Message),'错误',MB_OK+MB_ICONERROR);
  end;
end;

function TDM.GetDateTime: TDateTime;
begin
  Result:=Now;
end;

initialization
  TComponentFactory.Create(ComServer, TDM,
    CLASS_Test, ciMultiInstance, tmApartment);
end.
