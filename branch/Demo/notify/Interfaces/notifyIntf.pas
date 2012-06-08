unit notifyIntf;
{$weakpackageunit on}
interface

uses Forms;

const NotifyFlag=111;

Type
  IClsRegister=Interface
    ['{16AACD7D-7FCD-4C09-8D6A-4B0F462F7AC5}']
    procedure RegCls(const aName:string;cls:TFormClass);
    //procedure UnRegCls(const aName:string);
  End;
implementation

end.
