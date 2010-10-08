{------------------------------------
  功能说明：实现对注册表的读写，因为外部也可能
           会操作注册表，所以封装成一个DLL
  创建日期：2008/11/14
  作者：wzw
  版权：wzw
-------------------------------------}
unit RegObj;

interface

uses SysUtils,Classes,RegIntf,XMLDoc,XMLIntf,Variants,ActiveX,SvcInfoIntf
     ,MenuRegIntf;

Type
   TRegObj=Class(TInterfacedObject,IRegistry,ILoadRegistryFile,ISvcInfo,IMenuReg)
   private
     FRegFile:String;
     FXMLDoc:IXMLDocument;
     FCurrNode:IXMLNode;
     function GetNode(const key:Widestring;CanCreate:Boolean):IXMLNode;
     function ReadValue(const aName:Widestring;out Value:OleVariant):boolean;
     procedure WriteValue(const aName:Widestring;Value:OleVariant);
   protected
    {IRegistry}
     function OpenKey(const Key:Widestring;CanCreate:Boolean=False):boolean;
     function DeleteKey(const Key:Widestring):boolean;
     function KeyExists(const Key:Widestring):boolean;
     procedure GetKeyNames(Strings: TStrings);
     procedure GetValueNames(Strings: TStrings);
     function DeleteValue(const aName:Widestring):boolean;
     function ValueExists(const ValueName:Widestring):boolean;

     function ReadBool(const aName: Widestring;out Value: Boolean):boolean;
     function ReadDate(const aName: Widestring;out Value: TDateTime):boolean;
     function ReadDateTime(const aName: Widestring; out Value: TDateTime):boolean;
     function ReadFloat(const aName: Widestring; out Value: Double):boolean;
     function ReadInteger(const aName: Widestring; out Value: Integer):boolean;
     function ReadString(const aName:Widestring; out Value: Widestring):boolean;
     function ReadTime(const aName: Widestring; out Value: TDateTime):boolean;

     procedure WriteBool(const aName: Widestring; Value: Boolean);
     procedure WriteDate(const aName: Widestring; Value: TDateTime);
     procedure WriteDateTime(const aName: Widestring; Value: TDateTime);
     procedure WriteFloat(const aName: Widestring; Value: Double);
     procedure WriteInteger(const aName: Widestring; Value: Integer);
     procedure WriteString(const aName, Value: Widestring);
     procedure WriteTime(const aName: Widestring; Value: TDateTime);

     procedure SaveData;

     {ILoadRegistryFile}
     procedure LoadRegistryFile(const FileName:Widestring);
     {ISvcInfo}
     function GetModuleName:String;
     function GetTitle:String;
     function GetVersion:String;
     function GetComments:String;
     {IMenuReg}
     procedure RegMenu(const Key,Path:WideString);
     procedure UnRegMenu(const Key:WideString);
     procedure RegToolItem(const Key,aCaption,aHint:WideString);
     procedure UnRegToolItem(const Key:WideString);
   public
     //constructor Create;;
     Destructor Destroy;override;
   End;

   ERegistryException=Class(Exception);

implementation

const MenuKey='SYSTEM\MENU';
      ToolKey='SYSTEM\TOOL';

function TRegObj.DeleteKey(const Key: Widestring): boolean;
var Node:IXMLNode;
begin
  Result:=False;
  if Trim(key)='' then exit;
  Node:=GetNode(Key,False);
  if assigned(Node) then
    Result:=Node.ParentNode.ChildNodes.Remove(Node)<>-1;
end;

function TRegObj.DeleteValue(const aName: Widestring): boolean;
var Node:IXMLNode;
begin
  Result:=False;
  if trim(aName)='' then exit;
  if assigned(FCurrNode) then
  begin
    Node:=FCurrNode.AttributeNodes.FindNode(WideUpperCase(aName));
    if assigned(Node) then
      Result:=FCurrNode.AttributeNodes.Remove(Node)<>-1;
  end;
end;

destructor TRegObj.Destroy;
begin
  FXMLDoc:=nil;
  FCurrNode:=nil;
  inherited;
end;

function TRegObj.GetComments: String;
begin
  Result:='框架注册表服务接口，用于操作框架注册表。';
end;

procedure TRegObj.GetKeyNames(Strings: TStrings);
var i:integer;
begin
  if Strings=Nil then Exit;
  if assigned(FCurrNode) then
  begin
    if FCurrNode.HasChildNodes then
    begin
      for i:=0 to FCurrNode.ChildNodes.Count-1 do
        Strings.Add(FCurrNode.ChildNodes[i].NodeName);
    end;
  end;
end;

function TRegObj.GetModuleName: String;
begin
  Result:=ExtractFileName(SysUtils.GetModuleName(HInstance));
end;

function TRegObj.GetNode(const key: Widestring;CanCreate:Boolean): IXMLNode;
  //内部函数
  function InnerGetNode(const NodeStr:Widestring;FromNode:IXMLNode;
    aCanCreate:Boolean):IXMLNode;
  begin
    Result:=Nil;
    if Trim(NodeStr)='' then exit;
    if FromNode=Nil then exit;
    if aCanCreate then
      Result:=FromNode.ChildNodes[NodeStr]
    else Result:=FromNode.ChildNodes.FindNode(NodeStr);
  end;
var aList:TStrings;
    ParentNode,FoundNode:IXMLNode;
    i:integer;
    tmpKey:String;
begin
  tmpKey:=UpperCase(Trim(key));//WideUpperCase
  if tmpKey='' then
  Begin
    Result:=FXMLDoc.DocumentElement;
    Exit;
  End;
  ParentNode:=FXMLDoc.DocumentElement;
  aList:=TStringList.Create;
  try
    ExtractStrings(['\'],[],pchar(tmpKey),aList);
    for i := 0 to aList.Count - 1 do
    begin
      FoundNode:=InnerGetNode(aList[i],ParentNode,CanCreate);
      if FoundNode=Nil then Exit;
      ParentNode:=FoundNode;
    end;
    Result:=FoundNode;//同上
  Finally
    aList.Free;
  end;
end;

function TRegObj.GetTitle: String;
begin
  Result:='注册表接口(IRegistry)';
end;

procedure TRegObj.GetValueNames(Strings: TStrings);
var i:integer;
begin
  if Strings=Nil then Exit;
  if assigned(FCurrNode) then
  begin
    for i := 0 to FCurrNode.AttributeNodes.Count - 1 do
      Strings.Add(FCurrNode.AttributeNodes[i].NodeName);
   end;
end;

function TRegObj.GetVersion: String;
begin
  Result:='20100421.001';
end;

function TRegObj.KeyExists(const Key: Widestring): boolean;
var tmpNode:IXMLNode;
begin
  tmpNode:=GetNode(Key,False);
  Result:=tmpNode<>Nil;
end;

procedure TRegObj.LoadRegistryFile(const FileName: Widestring);
begin
  Try
    FRegFile:=FileName;
    FXMLDoc:=LoadXMLDocument(FileName);
  Except
    on E:Exception do
      Raise ERegistryException.CreateFmt('打开注册表出错：%s',[E.Message]);
  End;
end;

function TRegObj.OpenKey(const Key: Widestring; CanCreate: Boolean): boolean;
begin
  FCurrNode:=GetNode(Key,CanCreate);
  Result:=Assigned(FCurrNode);
end;

function TRegObj.ReadBool(const aName: Widestring; out Value: Boolean): boolean;
var tmpValue:OleVariant;
begin
  Result:=ReadValue(aName,tmpValue);
    if VarIsNull(tmpValue) then
    Value:=False
  else Value:=tmpValue;
end;

function TRegObj.ReadDate(const aName: Widestring; out Value: TDateTime): boolean;
var tmpValue:OleVariant;
begin
  Result:=ReadValue(aName,tmpValue);
    if VarIsNull(tmpValue) then
    Value:=0
  else Value:=tmpValue;
end;

function TRegObj.ReadDateTime(const aName: Widestring;out Value: TDateTime): boolean;
var tmpValue:OleVariant;
begin
  Result:=ReadValue(aName,tmpValue);
    if VarIsNull(tmpValue) then
    Value:=0
  else Value:=tmpValue;
end;

function TRegObj.ReadFloat(const aName: Widestring;out Value: Double): boolean;
var tmpValue:OleVariant;
begin
  Result:=ReadValue(aName,tmpValue);
    if VarIsNull(tmpValue) then
    Value:=0.0
  else Value:=tmpValue;
end;

function TRegObj.ReadInteger(const aName: Widestring;out Value: Integer): boolean;
var tmpValue:OleVariant;
begin
  Result:=ReadValue(aName,tmpValue);
    if VarIsNull(tmpValue) then
    Value:=0
  else Value:=tmpValue;
end;

function TRegObj.ReadString(const aName:Widestring; out Value: Widestring): boolean;
var tmpValue:OleVariant;
begin
  Result:=ReadValue(aName,tmpValue);
  if VarIsNull(tmpValue) then
    Value:=''
  else Value:=tmpValue;
end;

function TRegObj.ReadTime(const aName: Widestring;out Value: TDateTime): boolean;
var tmpValue:OleVariant;
begin
  Result:=ReadValue(aName,tmpValue);
    if VarIsNull(tmpValue) then
    Value:=0
  else Value:=tmpValue;
end;

function TRegObj.ReadValue(const aName: Widestring; out Value: OleVariant): boolean;
var Node:IXMLNode;
begin
  Result:=False;
  if assigned(FCurrNode) then
  begin
    Node:=FCurrNode.AttributeNodes.FindNode(WideUpperCase(aName));
    if assigned(Node) then
    begin
      Value:=Node.NodeValue;
      Result:=True;
    end;
  end;
end;

procedure TRegObj.RegMenu(const Key, Path: WideString);
begin
  if Key='' then exit;
  if self.OpenKey(MenuKey,True) then
    self.WriteString(Key,Path);
end;

procedure TRegObj.RegToolItem(const Key, aCaption, aHint: WideString);
var S:WideString;
begin
  if Key='' then exit;
  if self.OpenKey(ToolKey,True) then
  begin
    S:='Caption='+aCaption+',Hint='+aHint;
    self.WriteString(Key,S);
  end;
end;

procedure TRegObj.SaveData;
begin
  if FXMLDoc.Modified then
    FXMLDoc.SaveToFile(FRegFile);
end;

procedure TRegObj.UnRegMenu(const Key: WideString);
begin
  if Key='' then exit;
  if self.OpenKey(MenuKey) then
    self.DeleteValue(Key);
end;

procedure TRegObj.UnRegToolItem(const Key: WideString);
begin
  if Key='' then exit;
  if self.OpenKey(ToolKey) then
    self.DeleteValue(Key);
end;

function TRegObj.ValueExists(const ValueName: Widestring): boolean;
begin
  Result:=False;
  if assigned(FCurrNode) then
    Result:=FCurrNode.AttributeNodes.FindNode(WideUpperCase(ValueName))<>Nil;
end;

procedure TRegObj.WriteBool(const aName: Widestring; Value: Boolean);
begin
  WriteValue(aName,Value);
end;

procedure TRegObj.WriteDate(const aName: Widestring; Value: TDateTime);
begin
  WriteValue(aName,Value);
end;

procedure TRegObj.WriteDateTime(const aName: Widestring; Value: TDateTime);
begin
  WriteValue(aName,Value);
end;

procedure TRegObj.WriteFloat(const aName: Widestring; Value: Double);
begin
  WriteValue(aName,Value);
end;

procedure TRegObj.WriteInteger(const aName: Widestring; Value: Integer);
begin
  WriteValue(aName,Value);
end;

procedure TRegObj.WriteString(const aName, Value: Widestring);
begin
  WriteValue(aName,Value);
end;

procedure TRegObj.WriteTime(const aName: Widestring; Value: TDateTime);
begin
  WriteValue(aName,Value);
end;

procedure TRegObj.WriteValue(const aName: Widestring; Value: OleVariant);
begin
  if assigned(FCurrNode) then
    FCurrNode.Attributes[WideUpperCase(aName)]:=value;
end;

initialization
  CoInitialize(nil);
finalization
  CoUninitialize;
end.
