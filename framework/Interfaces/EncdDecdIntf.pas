{------------------------------------
  功能说明：系统加密接口
  创建日期：2008/12/21
  作者：wzw
  版权：wzw
-------------------------------------}
unit EncdDecdIntf;
{$weakpackageunit on}
interface

uses Classes;

Type
  IEncdDecd=Interface
    ['{08487D9D-4CCB-41D5-B1A0-543FCE2281F1}']
    function Encrypt(const Key,SrcStr:String):String;
    function Decrypt(const Key,SrcStr:String):String;
    function MD5(const Input:string):string;

    procedure Base64EncodeStream(Input, Output: TStream);
    procedure Base64DecodeStream(Input, Output: TStream);
    function  Base64EncodeString(const Input: string): string;
    function  Base64DecodeString(const Input: string): string;
  End;
implementation

end.
