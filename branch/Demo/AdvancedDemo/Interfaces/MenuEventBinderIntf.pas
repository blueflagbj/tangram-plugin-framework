{------------------------------------
  功能说明：菜单事件分发接口
  创建日期：2010/04/23
  作者：wzw
  版权：wzw
-------------------------------------}
unit MenuEventBinderIntf;
{$weakpackageunit on}
interface

uses Classes,Graphics;

Type
  IMenuEventBinder=Interface
    ['{1B1BA5A6-097F-422F-83E8-952B5EE451CB}']
    procedure RegMenuEvent(const Key:String;MenuClick:TNotifyEvent);
    procedure RegToolEvent(const Key:String;ToolClick:TNotifyEvent;Img:TGraphic);
    //function GetObj(const Key:String):TObject;
  end;
  
implementation


end.
