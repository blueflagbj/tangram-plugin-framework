unit uDM;

interface

uses
  SysUtils, Classes, Controls,DB, DBClient, MConnect, SConnect,DBIntf,
  InvokeServerIntf,SvcInfoIntf;

type
  Tdm = class(TDataModule,IDBConnection,IDBAccess,IInvokeServer,ISvcInfoEx)
    Conn: TSocketConnection;
  private
    function CheckConnct:Boolean;
  protected
  {IDBConnection}
    function GetConnected:Boolean;
    procedure SetConnected(Const Value:Boolean);
    property Connected:Boolean Read GetConnected Write SetConnected;
    procedure ConnConfig;
    function GetDBConnection:TObject;
  {IDBAccess}
    procedure BeginTrans;
    procedure CommitTrans;
    procedure RollbackTrans;

    procedure QuerySQL(Cds:TClientDataSet;Const SQLStr:String);

    procedure ExecuteSQL(Const SQLStr:String);
    procedure ApplyUpdate(Const TableName:String;Cds:TClientDataSet);
    {IInvokeServer}
    function AppServer:Variant;

    {ISvcInfoEx}
    procedure GetSvcInfo(Intf:ISvcInfoGetter);
  public
    { Public declarations }
  end;

var
  dm: Tdm;

implementation

uses SysSvc,_sys,RegIntf,DialogIntf,uConfig;

{$R *.dfm}
Const Key_DBConn='SYSTEM\DBCONNECTION';
      Key_IPAddr='IPADDR';
      Key_Port='PORT';
{ Tdm }

procedure Tdm.ApplyUpdate(const TableName: String; Cds: TClientDataSet);
var r:Shortint;
begin
  CheckConnct;
  if Cds.State in [dsEdit, dsInsert] then cds.Post;
  if Cds.ChangeCount=0 then exit;
  r:=self.Conn.AppServer.ApplyUpdate(TableName,Cds.Delta);
  if r=1 then
    Cds.MergeChangeLog
  else (SysService as IDialog).ShowError('提交数据出错！');
end;

procedure Tdm.BeginTrans;
begin
  //方法未实现...
end;

procedure Tdm.CommitTrans;
begin
  //方法未实现...
end;

procedure Tdm.RollbackTrans;
begin
  //方法未实现...
end;

procedure Tdm.ExecuteSQL(const SQLStr: String);
begin
  CheckConnct;
  self.Conn.AppServer.ExecSQL(SQLStr);
end;

function Tdm.GetConnected: Boolean;
begin
  Result:=self.Conn.Connected;
end;

function Tdm.GetDBConnection: TObject;
begin
  Result:=self.Conn;
end;

procedure Tdm.QuerySQL(Cds: TClientDataSet; const SQLStr: String);
begin
  CheckConnct;
  Cds.Data:=self.Conn.AppServer.QryData(SQLStr);
end;

procedure Tdm.ConnConfig;
var Reg:IRegistry;
    IpAddr:Widestring;
    Port:Integer;
begin
  Reg:=SysService as IRegistry;
  if Reg.OpenKey(Key_DBConn,True) then
  begin
    frmConfig:=TfrmConfig.Create(nil);
    try
      Reg.ReadString(Key_IPAddr,IPAddr);
      Reg.ReadInteger(Key_Port,Port);
      frmConfig.edt_IPAddr.Text:=IPAddr;
      frmConfig.edt_Port.Text:=Inttostr(Port);
      if frmConfig.ShowModal=mrOK then
      begin
        IpAddr:=frmConfig.edt_IPAddr.Text;
        Port:=StrToIntDef(frmConfig.edt_Port.Text,211);
        Reg.WriteString(Key_IPAddr,IpAddr);
        Reg.WriteInteger(Key_Port,Port);
        Reg.SaveData;

        self.Conn.Connected:=False;
        self.Conn.Host:=IpAddr;
        self.Conn.Port:=Port;
        self.Conn.Connected:=True;
      end;
    finally
      frmConfig.Free;
    end;
  end;
end;

procedure Tdm.SetConnected(const Value: Boolean);
begin
  self.Conn.Connected:=Value;
end;

function Tdm.CheckConnct:Boolean;
var Reg:IRegistry;
    IpAddr:Widestring;
    Port:Integer;
begin
  Result:=True;
  if self.Conn.Connected then exit;
  try
    Reg:=SysService as IRegistry;
    if Reg.OpenKey(Key_DBConn,True) then
    begin
      Reg.ReadString(Key_IPAddr,IPAddr);
      Reg.ReadInteger(Key_Port,Port);
      self.Conn.Address:=IpAddr;
      self.Conn.Port:=Port;
      self.Conn.Connected:=True;
      Result:=True;
    end;
  Except
    on E:Exception do
      (SysService as IDialog).ShowError(E);
  end;
end;

function Tdm.AppServer: Variant;
begin
  Result:=self.Conn.AppServer;
end;

procedure Tdm.GetSvcInfo(Intf: ISvcInfoGetter);
var SvcInfoRec:TSvcInfoRec;
begin
  SvcInfoRec.ModuleName:=ExtractFileName(SysUtils.GetModuleName(HInstance));
  SvcInfoRec.GUID:=GUIDToString(IDBConnection);
  SvcInfoRec.Title:='Midas连接接口(IDBConnection)';
  SvcInfoRec.Version:='20100609.001';
  SvcInfoRec.Comments:='用于连接Midas中间层服务器';
  Intf.SvcInfo(SvcInfoRec);

  SvcInfoRec.GUID:=GUIDToString(IDBAccess);
  SvcInfoRec.Title:='Midas数据库访问接口(IDBAccess)';
  SvcInfoRec.Version:='20100609.001';
  SvcInfoRec.Comments:='用于操作数据库';
  Intf.SvcInfo(SvcInfoRec);

  SvcInfoRec.GUID:=GUIDToString(IInvokeServer);
  SvcInfoRec.Title:='Midas远程方法调用接口(IInvokeServer)';
  SvcInfoRec.Version:='20100609.001';
  SvcInfoRec.Comments:='用于远程方法调用';
  Intf.SvcInfo(SvcInfoRec);
end;

end.
