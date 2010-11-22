object frm_Main: Tfrm_Main
  Left = 206
  Top = 166
  Caption = #20027#31383#20307
  ClientHeight = 385
  ClientWidth = 633
  Color = clAppWorkSpace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = MainMenu
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 366
    Width = 633
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 150
      end
      item
        Width = 150
      end
      item
        Width = 200
      end>
    ExplicitTop = 1
    ExplicitWidth = 115
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 633
    Height = 29
    Caption = 'ToolBar1'
    Color = clBtnFace
    EdgeBorders = [ebTop, ebBottom]
    Images = ImageList1
    ParentColor = False
    TabOrder = 1
    Transparent = False
    ExplicitWidth = 115
  end
  object MainMenu: TMainMenu
    Left = 24
    Top = 80
  end
  object ImageList1: TImageList
    Left = 56
    Top = 80
  end
end
