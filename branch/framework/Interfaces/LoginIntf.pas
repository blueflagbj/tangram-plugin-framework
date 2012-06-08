{------------------------------------
  功能说明：登录接口
  创建日期：2008/12/29
  作者：wzw
  版权：wzw
-------------------------------------}
unit LoginIntf;

interface
{$weakpackageunit on}
Type
  ILogin=Interface
    ['{694033A7-8C4F-4FCC-ABA9-01ECD1FF4F28}']
    function Login:Boolean;
    procedure ChangeUser;
    procedure LockSystem;
  End;
implementation

end.
