unit SysSvcIntf;

interface

uses NotifyServiceIntf,ModuleLoaderIntf;

Type
  ISysService=Interface
  ['{782CE8B0-66C0-4211-9A78-C54E19DBC5B3}']
    function Notify:INotifyService;
    function ModuleLoader:IModuleLoader;
  End;
implementation

end.
