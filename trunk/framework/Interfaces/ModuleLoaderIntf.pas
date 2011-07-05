{------------------------------------
  功能说明：模块加载接口，用户可以通过这个接口自已加载
            模块，不使用框架默认的从注册表加载模块
  创建日期：2011/02/24
  作者：wei
  版权：wei
-------------------------------------}
unit ModuleLoaderIntf;
{$weakpackageunit on}
interface

Type
  IModuleLoader=Interface
    ['{04EBD77D-1313-4469-B522-1ABC2A40DD49}']
    procedure LoadBegin;
    procedure LoadModuleFromFile(const ModuleFile: string);
    procedure LoadModulesFromDir(const Dir:String='');
    procedure LoadFinish;
    procedure UnLoadModule(const ModuleFile:string);
    function ModuleLoaded(const ModuleFile:string):Boolean;
  End;

implementation

end.
