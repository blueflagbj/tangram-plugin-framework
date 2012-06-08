object frm_Login: Tfrm_Login
  Left = 393
  Top = 269
  BorderStyle = bsDialog
  Caption = #31995#32479#30331#24405
  ClientHeight = 173
  ClientWidth = 327
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 40
    Top = 35
    Width = 24
    Height = 13
    Caption = #29992#25143
  end
  object Label2: TLabel
    Left = 40
    Top = 69
    Width = 24
    Height = 13
    Caption = #21475#20196
  end
  object edt_Psw: TEdit
    Left = 80
    Top = 66
    Width = 177
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
  end
  object btn_Ok: TBitBtn
    Left = 80
    Top = 107
    Width = 75
    Height = 25
    Caption = #30830#23450
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 2
    OnClick = btn_OkClick
  end
  object btn_Cancel: TBitBtn
    Left = 182
    Top = 107
    Width = 75
    Height = 25
    Cancel = True
    Caption = #21462#28040
    DoubleBuffered = True
    ModalResult = 2
    ParentDoubleBuffered = False
    TabOrder = 3
  end
  object edt_UserName: TEdit
    Left = 80
    Top = 32
    Width = 177
    Height = 21
    TabOrder = 0
  end
end
