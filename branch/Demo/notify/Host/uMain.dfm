object FrmMain: TFrmMain
  Left = 219
  Top = 192
  BorderStyle = bsDialog
  Caption = 'Notify Demo'
  ClientHeight = 431
  ClientWidth = 679
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lst_sel: TListBox
    Left = 16
    Top = 16
    Width = 137
    Height = 385
    ItemHeight = 13
    TabOrder = 0
    OnClick = lst_selClick
  end
  object pnl_view: TPanel
    Left = 168
    Top = 16
    Width = 489
    Height = 385
    Caption = 'pnl_view'
    TabOrder = 1
  end
end
