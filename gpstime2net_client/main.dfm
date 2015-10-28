object Form1: TForm1
  Left = 192
  Top = 109
  Width = 331
  Height = 137
  Caption = 'GPS time to network (client)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 8
    Top = 16
    Width = 32
    Height = 13
    Caption = 'Server'
  end
  object lbl2: TLabel
    Left = 8
    Top = 48
    Width = 20
    Height = 13
    Caption = 'Port'
  end
  object Label1: TLabel
    Left = 8
    Top = 80
    Width = 26
    Height = 13
    Caption = 'Time:'
  end
  object edt1: TEdit
    Left = 48
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '192.168.1.101'
  end
  object edt2: TEdit
    Left = 48
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '1212'
  end
  object btn1: TButton
    Left = 192
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 2
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 192
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Sync'
    Enabled = False
    TabOrder = 3
    OnClick = btn2Click
  end
  object ComboBox1: TComboBox
    Left = 48
    Top = 72
    Width = 121
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 4
    Text = 'Local time'
    Items.Strings = (
      'Local time'
      'GPS time')
  end
  object clntsckt1: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnecting = clntsckt1Connecting
    OnConnect = clntsckt1Connect
    OnDisconnect = clntsckt1Disconnect
    OnRead = clntsckt1Read
    OnError = clntsckt1Error
    Left = 280
    Top = 8
  end
end
