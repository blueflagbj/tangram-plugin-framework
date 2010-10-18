{------------------------------------
  功能说明：包导出的函数
  创建日期：2008/11/19
  作者：wzw
  版权：wzw
-------------------------------------}
unit PackageExport;
//{$weakpackageunit on}
interface

uses RegIntf;

Type
  TLoad=procedure (Intf:IInterface);//加载包后调用
  TInit=procedure ;//初始化包(加载所有包后调用）
  TFinal=procedure;//程序退出前调用

  TInstallPackage=procedure (Reg:IRegistry);//安装包
  TUnInstallPackage=procedure (Reg:IRegistry);//卸载包

implementation

end.
