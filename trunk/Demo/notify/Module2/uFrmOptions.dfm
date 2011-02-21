object FrmOptions: TFrmOptions
  Left = 0
  Top = 0
  Caption = 'FrmOptions'
  ClientHeight = 329
  ClientWidth = 504
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 504
    Height = 329
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 473
    ExplicitHeight = 297
    object TabSheet1: TTabSheet
      Caption = #24120#35268
      ExplicitWidth = 281
      ExplicitHeight = 165
      object CheckBox1: TCheckBox
        Left = 40
        Top = 32
        Width = 97
        Height = 17
        Caption = 'CheckBox1'
        TabOrder = 0
      end
      object CheckBox2: TCheckBox
        Left = 40
        Top = 56
        Width = 97
        Height = 17
        Caption = 'CheckBox2'
        TabOrder = 1
      end
      object RadioButton1: TRadioButton
        Left = 40
        Top = 120
        Width = 113
        Height = 17
        Caption = 'RadioButton1'
        TabOrder = 2
      end
      object RadioButton2: TRadioButton
        Left = 40
        Top = 160
        Width = 113
        Height = 17
        Caption = 'RadioButton2'
        TabOrder = 3
      end
      object ComboBox1: TComboBox
        Left = 184
        Top = 32
        Width = 145
        Height = 21
        TabOrder = 4
        Text = 'ComboBox1'
      end
      object ComboBox2: TComboBox
        Left = 184
        Top = 56
        Width = 145
        Height = 21
        TabOrder = 5
        Text = 'ComboBox2'
      end
    end
    object TabSheet2: TTabSheet
      Caption = #39640#32423
      ImageIndex = 1
      ExplicitWidth = 281
      ExplicitHeight = 165
      object Memo1: TMemo
        Left = 24
        Top = 24
        Width = 417
        Height = 89
        Lines.Strings = (
          'Memo1')
        TabOrder = 0
      end
    end
  end
end
