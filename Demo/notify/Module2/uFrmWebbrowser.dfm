object FrmWebbrowser: TFrmWebbrowser
  Left = 0
  Top = 0
  Caption = 'FrmWebbrowser'
  ClientHeight = 402
  ClientWidth = 614
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    614
    402)
  PixelsPerInch = 96
  TextHeight = 13
  object cb_url: TComboBox
    Left = 8
    Top = 8
    Width = 518
    Height = 21
    ParentCustomHint = False
    Anchors = [akLeft, akTop, akRight]
    ItemIndex = 0
    TabOrder = 0
    Text = 'http://code.google.com/p/tangram-plugin-framework/'
    Items.Strings = (
      'http://code.google.com/p/tangram-plugin-framework/')
    ExplicitWidth = 524
  end
  object Button1: TButton
    Left = 532
    Top = 8
    Width = 63
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #25171#24320
    TabOrder = 1
    OnClick = Button1Click
    ExplicitLeft = 538
  end
  object WebBrowser1: TWebBrowser
    Left = 8
    Top = 39
    Width = 594
    Height = 352
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    ControlData = {
      4C000000643D0000612400000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
end
