{------------------------------------
  功能说明：等待窗体接口
  创建日期：2008/11/29
  作者：wzw
  版权：wzw
-------------------------------------}
unit ProgressFormIntf;
{$weakpackageunit on}
interface
Type
  IProgressForm=Interface
    ['{B5D75EE6-AA74-461F-817F-2944C4D7A2AE}']
    procedure ShowMsg(const MsgStr:String);
    procedure progress(const Max,Position:Integer);
    procedure Hide;
  End;

implementation

end.
