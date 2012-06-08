object frmDLL: TfrmDLL
  Left = 0
  Top = 0
  Caption = 'DLL'#31383#21475
  ClientHeight = 218
  ClientWidth = 398
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
    Caption = #36825#26159'DLL'#27169#22359#37324#30340#31383#21475
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Button1: TButton
    Left = 208
    Top = 88
    Width = 145
    Height = 25
    Caption = #35774#32622#20027#31383#20307#26631#39064
    TabOrder = 0
    OnClick = Button1Click
  end
  object edt_Caption: TEdit
    Left = 57
    Top = 90
    Width = 145
    Height = 21
    TabOrder = 1
    Text = #20027#31383#21475#26631#39064
  end
  object Button2: TButton
    Left = 208
    Top = 119
    Width = 145
    Height = 25
    Caption = #35774#32622#20027#31383#20307#39068#33394
    TabOrder = 2
    OnClick = Button2Click
  end
  object ColorBox1: TColorBox
    Left = 57
    Top = 121
    Width = 145
    Height = 22
    TabOrder = 3
  end
end
