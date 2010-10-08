unit MidServer_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 2010/09/25 21:42:22 from Type Library described below.

// ************************************************************************  //
// Type Lib: F:\Tangram FrameWork\MadisSvr\MidServer.tlb (1)
// LIBID: {FB361C3B-65CD-4D88-B531-D554770F557A}
// LCID: 0
// Helpfile: 
// HelpString: MidServer Library
// DepndLst: 
//   (1) v1.0 Midas, (C:\WINDOWS\system32\midas.dll)
//   (2) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, Midas, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  MidServerMajorVersion = 1;
  MidServerMinorVersion = 0;

  LIBID_MidServer: TGUID = '{FB361C3B-65CD-4D88-B531-D554770F557A}';

  IID_ITest: TGUID = '{9A4E798C-321F-441D-BA84-7DBA23D5B369}';
  CLASS_Test: TGUID = '{24FF8621-2B81-4F7F-B657-0B33F7139B9F}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ITest = interface;
  ITestDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  Test = ITest;


// *********************************************************************//
// Interface: ITest
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9A4E798C-321F-441D-BA84-7DBA23D5B369}
// *********************************************************************//
  ITest = interface(IAppServer)
    ['{9A4E798C-321F-441D-BA84-7DBA23D5B369}']
    function QryData(const SQL: WideString): OleVariant; safecall;
    function ApplyUpdate(const Tablename: WideString; Delta: OleVariant): Shortint; safecall;
    function ExecSQL(const SQL: WideString): Shortint; safecall;
    function GetDateTime: TDateTime; safecall;
  end;

// *********************************************************************//
// DispIntf:  ITestDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9A4E798C-321F-441D-BA84-7DBA23D5B369}
// *********************************************************************//
  ITestDisp = dispinterface
    ['{9A4E798C-321F-441D-BA84-7DBA23D5B369}']
    function QryData(const SQL: WideString): OleVariant; dispid 301;
    function ApplyUpdate(const Tablename: WideString; Delta: OleVariant): {??Shortint}OleVariant; dispid 302;
    function ExecSQL(const SQL: WideString): {??Shortint}OleVariant; dispid 303;
    function GetDateTime: TDateTime; dispid 304;
    function AS_ApplyUpdates(const ProviderName: WideString; Delta: OleVariant; MaxErrors: Integer; 
                             out ErrorCount: Integer; var OwnerData: OleVariant): OleVariant; dispid 20000000;
    function AS_GetRecords(const ProviderName: WideString; Count: Integer; out RecsOut: Integer; 
                           Options: Integer; const CommandText: WideString; var Params: OleVariant; 
                           var OwnerData: OleVariant): OleVariant; dispid 20000001;
    function AS_DataRequest(const ProviderName: WideString; Data: OleVariant): OleVariant; dispid 20000002;
    function AS_GetProviderNames: OleVariant; dispid 20000003;
    function AS_GetParams(const ProviderName: WideString; var OwnerData: OleVariant): OleVariant; dispid 20000004;
    function AS_RowRequest(const ProviderName: WideString; Row: OleVariant; RequestType: Integer; 
                           var OwnerData: OleVariant): OleVariant; dispid 20000005;
    procedure AS_Execute(const ProviderName: WideString; const CommandText: WideString; 
                         var Params: OleVariant; var OwnerData: OleVariant); dispid 20000006;
  end;

// *********************************************************************//
// The Class CoTest provides a Create and CreateRemote method to          
// create instances of the default interface ITest exposed by              
// the CoClass Test. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoTest = class
    class function Create: ITest;
    class function CreateRemote(const MachineName: string): ITest;
  end;

implementation

uses ComObj;

class function CoTest.Create: ITest;
begin
  Result := CreateComObject(CLASS_Test) as ITest;
end;

class function CoTest.CreateRemote(const MachineName: string): ITest;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Test) as ITest;
end;

end.
