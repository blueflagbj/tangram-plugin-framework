{------------------------------------
  功能说明：系统常量
  创建日期：2008/11/19
  作者：wzw
  版权：wzw
-------------------------------------}
unit uConst;
{$weakpackageunit on}
interface

const
  Key_System='SYSTEM';//注册表系统键
  key_LoadModule='SYSTEM\LOADMODULE';//注册表加载模块键
  key_User='USER';//注册表用户自定义键

  Value_Module='Module';//注册表关键字。。。
  Value_Load='LOAD';//

  SplashFormWaitTime=1500;//Flash窗口最少等待时间(毫秒)

  EncryptDefaultKey='aA#2%EF3x'; //默认加密键

  //以下常量在包初始化时用(即包导出单元的Initpackage方法的Flasgs参数的含意)
  Flags_RegAuthority=1;//注册权限
  Flags_CreateDB=2;//创建数据库

implementation

end.
