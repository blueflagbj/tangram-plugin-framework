inherited frm_ProgressForm: Tfrm_ProgressForm
  Left = 452
  Top = 409
  BorderStyle = bsNone
  Caption = 'frm_ProgressForm'
  ClientHeight = 87
  ClientWidth = 366
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pal_Msg: TPanel
    Left = 0
    Top = 0
    Width = 366
    Height = 87
    Align = alClient
    BevelInner = bvRaised
    Caption = 'pal_Msg'
    TabOrder = 0
    object ProgressBar: TProgressBar
      Left = 6
      Top = 61
      Width = 349
      Height = 16
      TabOrder = 0
    end
    object Animate1: TAnimate
      Left = 13
      Top = 12
      Width = 16
      Height = 16
      CommonAVI = aviFindComputer
      StopFrame = 8
    end
  end
end
