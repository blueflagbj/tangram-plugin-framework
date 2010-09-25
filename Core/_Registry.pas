{------------------------------------
  功能说明：本单元从Reg.dll创建注册表读写对象并注册入系统
  创建日期：2008/11/14
  作者：wzw
  版权：wzw
-------------------------------------}
unit _Registry;

interface

uses SysUtils,windows,Classes,RegIntf,RegObj;

//Type

implementation

uses SysSvc,SysFactory,IniFiles;

procedure CreateRegObj(out anInstance: IInterface);
var RegFile,IniFile,AppPath:String;
    Ini:TIniFile;
begin
  AppPath:=ExtractFilePath(ParamStr(0));
  IniFile:=AppPath+'Root.ini';
  ini:=TIniFile.Create(IniFile);
  try
    RegFile:=AppPath+ini.ReadString('Default','Reg','');
    anInstance:=TRegObj.Create;
    (anInstance as ILoadRegistryFile).LoadRegistryFile(RegFile);
  finally
    ini.Free;
  end;
end;

initialization
  TIntfFactory.Create(IRegistry,@CreateRegObj);
finalization

end.
