{------------------------------------
  功能说明：实现IDBConnection接口
  创建日期：2010/04/26
  作者：wzw
  版权：wzw
-------------------------------------}
unit DBConnection;

interface

uses SysUtils,Controls,ADODB,DBIntf,SvcInfoIntf;

Type
  TDBConnection=Class(TInterfacedObject,IDBConnection,ISvcInfo)
  private
    FConnection:TADOConnection;
  protected
    {IDBConnection}
    function GetConnected:Boolean;
    procedure SetConnected(Const Value:Boolean);

    procedure ConnConfig;
    function GetDBConnection:TObject;
    {ISvcInfo}
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;
  public
    Constructor Create;
    Destructor Destroy;override; 
  end;
  
implementation

uses SysSvc,SysFactory,RegIntf,DBConfig,EncdDecdIntf,_sys,ActiveX;

Const Key_DBConn='SYSTEM\DBCONNECTION';
      Key_ConnStr='CONNSTR';
      Key_EncdDecd='dbconn#$@';
{ TDBConnection }

function TDBConnection.GetComments: String;
begin
  Result:='用于连接数据库';
end;

function TDBConnection.GetModuleName: String;
begin
  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TDBConnection.GetTitle: String;
begin
  Result:='数据库连接接口(IDBConnection)';
end;

function TDBConnection.GetVersion: String;
begin
  Result:='20100426.001';
end;

function TDBConnection.GetConnected: Boolean;
begin
  Result:=FConnection.Connected;
end;

function TDBConnection.GetDBConnection: TObject;
begin
  Result:=FConnection;
end;

procedure TDBConnection.SetConnected(const Value: Boolean);
var ConnStr:WideString;
    Reg:IRegistry;
    EncdDecd:IEncdDecd;
begin
  if Value then
  begin
    if SysService.QueryInterface(IEncdDecd,EncdDecd)=S_OK then
    begin
      Reg:=SysService as IRegistry;
      if Reg.OpenKey(Key_DBConn) then
      begin
        if Reg.ReadString(Key_ConnStr,ConnStr) then
        begin
          FConnection.ConnectionString:=EncdDecd.Decrypt(Key_EncdDecd,ConnStr);
          FConnection.Connected:=Value;
        end;
      end;
    end else Raise Exception.Create('未找到IEncdDecd接口！');
  end else FConnection.Connected:=Value;
end;

procedure TDBConnection.ConnConfig;
var ConnStr:WideString;
    Intf:IEncdDecd;
    Reg:IRegistry;
begin
  Intf:=SysService as IEncdDecd;
  Reg:=SysService as IRegistry;
  if Reg.OpenKey(Key_DBConn,True) then
  begin
    Frm_DBConfig:=TFrm_DBConfig.Create(nil);
    try
      Reg.ReadString(Key_ConnStr,ConnStr);
      Frm_DBConfig.DBConnStr:=Intf.Decrypt(Key_EncdDecd,ConnStr);
      if Frm_DBConfig.ShowModal=mrOK then
      begin
        ConnStr:=Intf.Encrypt(Key_EncdDecd,Frm_DBConfig.DBConnStr);

        Reg.WriteString(Key_ConnStr,ConnStr);
        Reg.SaveData;
      end;
    finally
      Frm_DBConfig.Free;
    end;
  end;
end;

constructor TDBConnection.Create;
begin
  FConnection:=TADOConnection.Create(nil);
  FConnection.LoginPrompt:=False;
end;

destructor TDBConnection.Destroy;
begin
  FConnection.Free;
  inherited;
end;

function CreateDBConnection(param:Integer):TObject;
begin
  CoInitialize(nil);
  Result:=TDBConnection.Create;
  CoUnInitialize;
end;

initialization
  TSingletonFactory.Create(IDBConnection,@CreateDBConnection);

finalization

end.
