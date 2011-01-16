{------------------------------------
  功能说明：Test2包导出的菜单
  创建日期：2010.04.23
  作者：WZW
  版权：WZW
-------------------------------------}
unit Test2Plugin;

interface

uses SysUtils,Classes,Graphics,MainFormIntf,MenuRegIntf,
     uTangramModule,PluginBase,RegIntf;

Type
  TTest2Plugin=Class(TPlugin)
  private
    procedure MenuOnclick(Sender:TObject);
    procedure ToolOnclick(Sender:TObject);
    procedure DBConfigClick(Sender:TObject);

    procedure UseIntfClick(pIntf:IShortCutClick);
    procedure UseDBClick(pIntf:IShortCutClick);

    function CreateIconFromStrData(const StrData:String):TGraphic;
  public
    Constructor Create; override;
    Destructor Destroy; override;

    procedure Init; override;
    procedure final; override;
    procedure Register(Flags: Integer; Intf: IInterface); override;

    class procedure RegisterModule(Reg:IRegistry);override;
    class procedure UnRegisterModule(Reg:IRegistry);override;

    Class procedure RegMenu(Reg:IMenuReg);
    Class procedure UnRegMenu(Reg:IMenuReg);
  End;

implementation

uses SysSvc,MenuEventBinderIntf,Test2FrameUnit,_sys,EncdDecdIntf,Test2FrameDB,
     DBIntf,uConst,Test2DB, Test2Form2;

const
  ID_Test2Menu1 ='ID_30BD2CFF-2C81-4621-8878-2E9469A22E46';
  ID_ToolButton1='ID_C79B86D8-C0F4-4D7A-9968-CEE7B1D281D1';
  ID_ToolButton2='ID_94A4A556-AA6B-43A5-AB7E-4CB0D7846CCF';
  ID_ToolLine   ='ID_D2EFC657-B620-4FD3-8DFC-7F934A3E3157';
  //经过Base64编码后的图标数据
  ImgData='AAABAAEAEBAQAAAAAAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAwAAAAAAAAAAAAAAAAAAA'
         +'AAAAAAAAAAAAAACAAACAAAAAgIAAgAAAAIAAgACAgAAAgICAAMDAwAAAAP8AAP8AAAD//wD/AAAA'
         +'/wD/AP//AAD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHd3d3d3dwAAf7i4uLi3AAf7i4uL'
         +'i4BwB/i4uLi4cHB/i4uLi4sHcH//////9whwd3d3d3d3e3AH+Li4uLi4cAf7i4uP//9wB/i4uPd3'
         +'d3AAf///cAAAAAAHd3cAAAAAAAAAAAAAAAD//wAA//8AAOAAAADAAAAAwAAAAIAAAACAAAAAAAAA'
         +'AAAAAAAAAAAAgAAAAIAAAACAAQAAwH8AAOD/AAD//wAA';

  ImgData2='AAABAAIAICAQAAAAAADoAgAAJgAAABAQEAAAAAAAKAEAAA4DAAAoAAAAIAAAAEAAAAABAAQAAAAA'
          +'AIACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAgAAAAICAAIAAAACAAIAAgIAAAMDAwACAgIAA'
          +'AAD/AAD/AAAA//8A/wAAAP8A/wD//wAA////AAAAAAAAAAAAAATsQAAdkQAAAAAAAAAAAAAE7EAA'
          +'HZEAAAAAAAAEREREROxAAB2RAAAAAAAMTERERER+wAAfeQAAAAAExMTEJEREREQAAREAAAAAjExM'
          +'RkLExAcCAAhwAAAAiEzMzGIiJMQHAsAIcAAACIzMzMxiIiLMBwLMGHAAAIhszMzMwiACQAcALAAA'
          +'AACGzMzMzCKIgAiHiAAIAAAIgszMzMwih3iHd3eIjwAACCJszMzMIo9/93d3d/BwAIgsbMzHbCKP'
          +'+I////8HeHCHZ8zMwiIiKIIoiIiIh3hwhnZ8x3IiIiIiIszMzId4cIdnzHIiIiIiIizCzMSPeHCG'
          +'dvx3IiIiIiLMIszMiIhwhv//wvIiIiLMIizMzMTCAIZ///8iIiIiIiJ4zMzMJACG//98zyIszCIo'
          +'hMzEwkIAj2//Isx8zMzMwkxiIiQkAAh//3ImTMQsIiIiIiJCQAAI9///8izMzCzMTCIiJCAAAIf/'
          +'fyIiIsxswsYiIkIAAACPZ8/yIiIiIiIiIiQkAAAACPYnLCIiIiIiIiIiQAAAAACP/y9iwiIiIiIi'
          +'JAAAAAAACPf//EwiIiIiIiAAAAAAAACP9m/MIiIiIiIAAAAAAAAACI9y/CImwiKIAAAAAAAAAAAI'
          +'j2b2xmaIAAAAAAAAAAAAAAiIiIiIAAAAAAAA///gwf/gAMH/gADB/gAAwfwAAOP4AABj8AAAI+AA'
          +'AAPAAAADwAAAA4AAAAOAAAADAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABgAAA'
          +'A4AAAAPAAAAHwAAAB+AAAA/wAAAf+AAAP/wAAH/+AAD//4AD///gD/8oAAAAEAAAACAAAAABAAQA'
          +'AAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAgAAAAICAAIAAAACAAIAAgIAAAMDAwACA'
          +'gIAAAAD/AAD/AAAA//8A/wAAAP8A/wD//wAA////AAAAAATsABkQAAAABOwAGRAAAAAE7AAZEAAA'
          +'AMxwAAcAAARMzHAABwAATMwMAAAIAATMyHB3AABwDCzI+P//B3CCzMyMiIiHcIf3/MzMzI9wh/fM'
          +'bGIsiIAIfyLCYiwAAAj3YiIiIAAAAI98IiJAAAAACIfGiAAAAAAACIgAAAAA/hAAAP4QAAD+EAAA'
          +'+DkAAOA5AADAEAAAgAAAAIAAAAAAAAAAAAAAAAAAAACADwAAgA8AAMAfAADgPwAA+P8AAA==';

  InstallKey = 'SYSTEM\LOADPACKAGE\USER';
  ValueKey = 'Package=%s;load=True';
{ TTest2Plugin }

procedure TTest2Plugin.Register(Flags: Integer; Intf: IInterface);
begin
  if Flags = Flags_RegAuthority then // 注册权限
  begin
    TFrmTestDB.RegistryAuthority;
    TForm3.RegistryAuthority;
  end;
end;

class procedure TTest2Plugin.RegisterModule(Reg: IRegistry);
var
  ModuleFullName, ModuleName, Value: String;
begin
  // MessageBox(GetActiveWindow,'已经安装过了！','aa',MB_OK+MB_ICONWARNING);
  // 注册菜单
  self.RegMenu(Reg as IMenuReg);

  if Reg.OpenKey(InstallKey, True) then
  begin
    ModuleFullName := sysutils.GetModuleName(HInstance);
    ModuleName := ExtractFileName(ModuleFullName);
    Value := Format(ValueKey, [ModuleFullName]);
    Reg.WriteString(ModuleName, Value);
    Reg.SaveData;
  end;
end;

class procedure TTest2Plugin.UnRegisterModule(Reg: IRegistry);
var
  ModuleName: String;
begin
  // 取消注册菜单
  self.UnRegMenu(Reg as IMenuReg);

  if Reg.OpenKey(InstallKey) then
  begin
    ModuleName := ExtractFileName(sysutils.GetModuleName(HInstance));
    if Reg.DeleteValue(ModuleName) then
      Reg.SaveData;
  end;
end;

class procedure TTest2Plugin.RegMenu(Reg: IMenuReg);
begin
  Reg.RegMenu(ID_Test2Menu1     ,'文件\Test2包');
  Reg.RegToolItem(ID_ToolButton1,'设置','数据库连接设置！');
  Reg.RegToolItem(ID_ToolLine   ,'-','');//加一个分隔线
  Reg.RegToolItem(ID_ToolButton2,'测试2','这是Test2包注册的工具栏！');
end;



class procedure TTest2Plugin.UnRegMenu(Reg: IMenuReg);
begin
  Reg.UnRegMenu(ID_Test2Menu1);
  Reg.UnRegToolItem(ID_ToolButton1);
  Reg.UnRegToolItem(ID_ToolLine);
  Reg.UnRegToolItem(ID_ToolButton2);
end;

constructor TTest2Plugin.Create;
var  MainForm:IMainForm;
begin
  MainForm:=SysService as IMainForm;
  MainForm.RegShortCut('接口使用',self.UseIntfClick);
  MainForm.RegShortCut('数据库操作',self.UseDBClick);
end;

function TTest2Plugin.CreateIconFromStrData(const StrData: String): TGraphic;
var
  OutPutStream,InputStream:TStream;
  EncdDecd:IEncdDecd;
begin
  Result:=nil;
  if SysService.QueryInterface(IEncdDecd,EncdDecd)=S_OK then
  begin
    InputStream:=TStringStream.Create(StrData);
    OutPutStream:=TMemoryStream.Create;
    try
      EncdDecd.Base64DecodeStream(InputStream,OutPutStream);
      OutPutStream.Position:=0;
      Result:=TIcon.Create;
      Result.LoadFromStream(OutPutStream);
    finally
      InputStream.Free;
      OutPutStream.Free;
    end;
  end;
end;

procedure TTest2Plugin.MenuOnclick(Sender: TObject);
begin
  sys.Dialogs.ShowMessage('这个是Test2包注册的菜单！');
end;

procedure TTest2Plugin.UseIntfClick(pIntf: IShortCutClick);
begin
  pIntf.RegPanel(TFrame2);
end;

procedure TTest2Plugin.ToolOnclick(Sender: TObject);
begin
  sys.Dialogs.ShowMessage('你好！');
end;

procedure TTest2Plugin.UseDBClick(pIntf: IShortCutClick);
begin
  PIntf.RegPanel(TFrame3);
end;

procedure TTest2Plugin.DBConfigClick(Sender: TObject);
begin
  (SysService as IDBConnection).ConnConfig;
end;

destructor TTest2Plugin.Destroy;
begin

  inherited;
end;

procedure TTest2Plugin.final;
begin
  inherited;

end;

procedure TTest2Plugin.Init;
var MenuEventBinder:IMenuEventBinder;
    Icon:TGraphic;
begin
  MenuEventBinder:=SysService as IMenuEventBinder;

  MenuEventBinder.RegMenuEvent(ID_Test2Menu1,self.MenuOnclick);
  //第一个工具栏按扭
  Icon:=self.CreateIconFromStrData(ImgData2);
  try
    MenuEventBinder.RegToolEvent(ID_ToolButton1,self.DBConfigClick,Icon);//绑定事件
  finally
    Icon.Free;
  end;
  //第二个工具栏按扭
  Icon:=self.CreateIconFromStrData(ImgData);
  try
    MenuEventBinder.RegToolEvent(ID_ToolButton2,self.ToolOnclick,Icon);//绑定事件
  finally
    Icon.Free;
  end;
end;

initialization
  RegisterPluginClass(TTest2Plugin);
finalization

end.
