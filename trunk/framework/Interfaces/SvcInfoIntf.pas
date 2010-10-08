{------------------------------------
  功能说明：服务信息接口
  创建日期：2010/04/21
  作者：WZW
  版权：WZW
-------------------------------------}
unit SvcInfoIntf;
{$weakpackageunit on}
interface

Type
  ISvcInfo=Interface
  ['{A4AC764B-1306-4FC3-9A0F-524B25C56992}']
    function GetModuleName:String;
    function GetTitle:String;
    function GetVersion:String;
    function GetComments:String;
  end;
  /////////////////////////////////
  TSvcInfoRec=Record
    ModuleName:string;
    GUID:String;
    Title:string;
    Version:string;
    Comments:String;
  end;

  TEnumSvcInfoPro=procedure (const IID:String;const SvcInfo:TSvcInfoRec) of Object;
  
  //////////////////////////////////////////////////
  ISvcInfoGetter=Interface
  ['{3FD01240-5D5B-4164-A6B6-67CD9FA8E67F}']
    procedure SvcInfo(SvcInfo:TSvcInfoRec);
  end;
  ISvcInfoEx=Interface
  ['{11C9CC87-02F6-4EEF-98DD-388752E7BABD}']
    procedure GetSvcInfo(Intf:ISvcInfoGetter);
  end;
implementation

end.
 