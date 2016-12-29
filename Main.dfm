object MainFrm: TMainFrm
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Depth'
  ClientHeight = 558
  ClientWidth = 528
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox: TPaintBox
    Left = 8
    Top = 8
    Width = 512
    Height = 424
  end
  object Label1: TLabel
    Left = 398
    Top = 454
    Width = 109
    Height = 13
    Caption = 'Depth at mouse cursor'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
  end
  object DepthLbl: TLabel
    AlignWithMargins = True
    Left = 408
    Top = 473
    Width = 85
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = '--.--'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 539
    Width = 528
    Height = 19
    Panels = <
      item
        Width = 400
      end
      item
        Width = 50
      end>
    ExplicitLeft = 328
    ExplicitTop = 160
    ExplicitWidth = 0
  end
  object Panel4: TPanel
    Left = 8
    Top = 447
    Width = 369
    Height = 82
    TabOrder = 1
    object Label7: TLabel
      Left = 1
      Top = 1
      Width = 367
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Depth range'
      Color = 14536383
      ParentColor = False
      Transparent = False
      ExplicitWidth = 60
    end
    object Label3: TLabel
      Left = 11
      Top = 26
      Width = 20
      Height = 13
      Caption = 'Min:'
    end
    object Label5: TLabel
      Left = 7
      Top = 58
      Width = 24
      Height = 13
      Caption = 'Max:'
    end
    object MinDLbl: TLabel
      Left = 319
      Top = 26
      Width = 36
      Height = 13
      Caption = 'MinDLbl'
    end
    object MaxDLbl: TLabel
      Left = 319
      Top = 58
      Width = 36
      Height = 13
      Caption = 'MinDLbl'
    end
    object MinDSB: TScrollBar
      Left = 35
      Top = 24
      Width = 270
      Height = 17
      Max = 4096
      PageSize = 0
      Position = 1
      TabOrder = 0
      OnChange = MinDSBChange
    end
    object MaxDSB: TScrollBar
      Left = 37
      Top = 56
      Width = 268
      Height = 17
      Max = 4096
      PageSize = 0
      Position = 4096
      TabOrder = 1
      OnChange = MaxDSBChange
    end
  end
  object KinectTimer: TTimer
    Enabled = False
    Interval = 20
    OnTimer = KinectTimerTimer
    Left = 40
    Top = 21
  end
end
