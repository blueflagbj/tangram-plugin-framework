object FrmNewImptUntfUnit: TFrmNewImptUntfUnit
  Left = 356
  Top = 230
  BorderStyle = bsDialog
  Caption = #26032#22686#25509#21475#23454#29616#21333#20803
  ClientHeight = 294
  ClientWidth = 438
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 112
    Height = 13
    Caption = #31867#21517'('#19981#29992#21152'T'#21069#32512')'
  end
  object Label2: TLabel
    Left = 25
    Top = 54
    Width = 52
    Height = 13
    Caption = #27880#20876#24037#21378
  end
  object edt_className: TEdit
    Left = 139
    Top = 17
    Width = 169
    Height = 21
    TabOrder = 0
  end
  object cb_Factory: TComboBox
    Left = 139
    Top = 50
    Width = 169
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 1
    Text = 'TIntfFactory'
    Items.Strings = (
      'TIntfFactory'
      'TSingletonFactory')
  end
  object GroupBox1: TGroupBox
    Left = 26
    Top = 112
    Width = 391
    Height = 137
    TabOrder = 2
    object Label3: TLabel
      Left = 16
      Top = 21
      Width = 26
      Height = 13
      Caption = #21517#31216
    end
    object Label4: TLabel
      Left = 16
      Top = 50
      Width = 26
      Height = 13
      Caption = #29256#26412
    end
    object Label5: TLabel
      Left = 16
      Top = 80
      Width = 26
      Height = 13
      Caption = #35828#26126
    end
    object Edt_IntfName: TEdit
      Left = 80
      Top = 16
      Width = 201
      Height = 21
      TabOrder = 0
    end
    object edt_IntfVer: TEdit
      Left = 80
      Top = 48
      Width = 201
      Height = 21
      TabOrder = 1
    end
    object mm_IntfComments: TMemo
      Left = 80
      Top = 80
      Width = 265
      Height = 41
      TabOrder = 2
    end
  end
  object chk_IntfInfo: TCheckBox
    Left = 26
    Top = 92
    Width = 97
    Height = 17
    Caption = #22686#21152#25509#21475#35828#26126
    TabOrder = 3
    OnClick = chk_IntfInfoClick
  end
  object btn_OK: TBitBtn
    Left = 262
    Top = 262
    Width = 75
    Height = 25
    Caption = #30830#23450
    Default = True
    TabOrder = 4
    OnClick = btn_OKClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
  end
  object btn_Cancel: TBitBtn
    Left = 342
    Top = 262
    Width = 75
    Height = 25
    Caption = #21462#28040
    TabOrder = 5
    Kind = bkCancel
  end
end
