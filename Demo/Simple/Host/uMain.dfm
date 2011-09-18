object FrmMain: TFrmMain
  Left = 219
  Top = 230
  Caption = 'Simple Demo'
  ClientHeight = 277
  ClientWidth = 551
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 168
    Top = 45
    Width = 165
    Height = 13
    Caption = 'IIntf2'#25509#21475#26159#22312'DLL'#27169#22359#37324#23454#29616#30340
  end
  object Label2: TLabel
    Left = 168
    Top = 101
    Width = 165
    Height = 13
    Caption = 'IIntf3'#25509#21475#26159#22312'BPL'#27169#22359#37324#23454#29616#30340
  end
  object Button1: TButton
    Left = 32
    Top = 40
    Width = 121
    Height = 25
    Caption = #35843#29992'IIntf2'#25509#21475
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 32
    Top = 96
    Width = 121
    Height = 25
    Caption = #35843#29992'IIntf3'#25509#21475
    TabOrder = 1
    OnClick = Button2Click
  end
  object StaticText1: TStaticText
    Left = 64
    Top = 152
    Width = 417
    Height = 73
    AutoSize = False
    Caption = 
      #36825#26159#19968#20010#31616#21333#30340#25509#21475#20351#29992#20363#23376#65292#36890#36807#36825#20010#20363#23376#65292#20320#20250#21457#29616#22312'tangram'#26694#26550#20013#65292#20027#31243#24207#19982#27169#22359#65292#27169#22359#19982#27169#22359#20043#38388#30456#20114#35843#29992#26159#19968#20010#38750#24120#31616#21333#30340#20107 +
      #12290#20320#21482#38656#35201#30693#36947#25509#21475#23601#21487#20197#35843#29992#65292#32780#19981#24517#20851#24515#23427#26159#22312#21738#37324#12289#22914#20309#23454#29616#30340#12290
    TabOrder = 2
  end
  object Button3: TButton
    Left = 56
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 3
    OnClick = Button3Click
  end
end
