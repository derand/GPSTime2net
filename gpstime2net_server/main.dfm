object Form1: TForm1
  Left = 228
  Top = 130
  Width = 461
  Height = 139
  Caption = 'GPS time to network (server)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 47
    Height = 13
    Caption = 'GPS time:'
  end
  object Label2: TLabel
    Left = 120
    Top = 16
    Width = 124
    Height = 13
    Caption = '00/00/0000 00:00:00.000'
  end
  object Label3: TLabel
    Left = 16
    Top = 32
    Width = 70
    Height = 13
    Caption = 'Computer time:'
  end
  object Label4: TLabel
    Left = 120
    Top = 32
    Width = 124
    Height = 13
    Caption = '00/00/0000 00:00:00.000'
  end
  object Label5: TLabel
    Left = 16
    Top = 48
    Width = 100
    Height = 13
    Caption = 'Diff(TDateTimeNow):'
  end
  object Label6: TLabel
    Left = 120
    Top = 48
    Width = 32
    Height = 13
    Caption = 'Label6'
  end
  object Label7: TLabel
    Left = 8
    Top = 88
    Width = 32
    Height = 13
    Caption = 'Label7'
  end
  object Label8: TLabel
    Left = 120
    Top = 64
    Width = 32
    Height = 13
    Caption = 'Label8'
  end
  object Label9: TLabel
    Left = 16
    Top = 64
    Width = 91
    Height = 13
    Caption = 'Diff(GetTickCount):'
  end
  object Label10: TLabel
    Left = 280
    Top = 56
    Width = 71
    Height = 13
    Caption = 'Connections: 0'
  end
  object Button1: TButton
    Left = 368
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Sync'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 368
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Start server'
    TabOrder = 1
    OnClick = Button2Click
  end
  object AfComPort1: TAfComPort
    BaudRate = br4800
    ComNumber = 1
    OnDataRecived = AfComPort1DataRecived
    Left = 240
  end
  object srvrsckt1: TServerSocket
    Active = False
    Port = 1212
    ServerType = stThreadBlocking
    OnGetThread = srvrsckt1GetThread
    OnThreadStart = srvrsckt1ThreadChange
    OnThreadEnd = srvrsckt1ThreadChange
    Left = 272
  end
end
