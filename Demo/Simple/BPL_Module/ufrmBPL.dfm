object frmBPL: TfrmBPL
  Left = 0
  Top = 0
  Caption = 'BPL'#31383#21475
  ClientHeight = 289
  ClientWidth = 432
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 64
    Top = 24
    Width = 163
    Height = 16
    Caption = #36825#26159'BPL'#27169#22359#37324#30340#31383#21475
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 168
    Top = 85
    Width = 165
    Height = 13
    Caption = 'IIntf2'#25509#21475#26159#22312'DLL'#27169#22359#37324#23454#29616#30340
  end
  object Button1: TButton
    Left = 48
    Top = 80
    Width = 105
    Height = 25
    Caption = #35843#29992'IIntf2'#25509#21475
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 48
    Top = 136
    Width = 105
    Height = 25
    Caption = #35774#22791#20027#31383#21475#26631#39064
    TabOrder = 1
    OnClick = Button2Click
  end
end
