unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, DateUtils;

type
  TForm1 = class(TForm)
    edt1: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    edt2: TEdit;
    btn1: TButton;
    clntsckt1: TClientSocket;
    btn2: TButton;
    Label1: TLabel;
    ComboBox1: TComboBox;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure clntsckt1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure clntsckt1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure clntsckt1Connect(Sender: TObject; Socket: TCustomWinSocket);
    procedure clntsckt1Connecting(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure clntsckt1Disconnect(Sender: TObject;
      Socket: TCustomWinSocket);
  private
    { Private declarations }
    request_time: DWord;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btn1Click(Sender: TObject);
begin
  if clntsckt1.Active then
  begin
    clntsckt1.Active := False;
  end else begin
    btn1.Enabled := False;
    clntsckt1.Address := edt1.Text;
    clntsckt1.Port := StrToInt(edt2.Text);
    clntsckt1.Active := True;
  end;
end;

procedure TForm1.btn2Click(Sender: TObject);
begin
  if clntsckt1.Active then
  begin
    if ComboBox1.ItemIndex = 0 then
    begin
      request_time := GetTickCount;
      clntsckt1.Socket.SendText('time');
    end else if ComboBox1.ItemIndex = 1 then
    begin
      request_time := GetTickCount;
      clntsckt1.Socket.SendText('gps');
    end;
  end else begin
    ShowMessage('Not connected to server');
  end;
end;

procedure TForm1.clntsckt1Read(Sender: TObject; Socket: TCustomWinSocket);
var
  buff: string;
  ticks, net_ticks, server_calc_ticks, add_ticks: DWord;
  vsys : _SYSTEMTIME;
  dt: TDateTime;
begin
  //ShowMessage(Socket.ReceiveText);
  ticks := GetTickCount;
  net_ticks := ticks - request_time;
  buff := Socket.ReceiveText;
  if Length(buff) > 24 then
  begin
    try
      vsys.wDay := StrToInt(Copy(buff, 1, 2));
      vsys.wMonth := StrToInt(Copy(buff, 4, 2));
      vsys.wYear := StrToInt(Copy(buff, 7, 4));
      vsys.wHour := StrToInt(Copy(buff, 12, 2));
      vsys.wMinute := StrToInt(Copy(buff, 15, 2));
      vsys.wSecond := StrToInt(Copy(buff, 18, 2));
      vsys.wMilliseconds := StrToInt(Copy(buff, 21, 3));
      server_calc_ticks := StrToInt(Copy(buff, 25, Length(buff)-24));
    except
      ShowMessage('Error converting string: ' + buff);
      Exit;
    end;
    add_ticks := GetTickCount - ticks + (net_ticks - server_calc_ticks) div 2;
    if add_ticks = 0 then
    begin
      if ComboBox1.ItemIndex = 0 then SetLocalTime(vsys)
      else SetSystemTime(vsys);
    end else begin
      dt := EncodeDateTime(vsys.wYear, vsys.wMonth, vsys.wDay, vsys.wHour, vsys.wMinute, vsys.wSecond, vsys.wMilliseconds);
      dt := IncMillisecond(dt, GetTickCount - ticks + (net_ticks - server_calc_ticks) div 2);
      DecodeDate(dt, vsys.wYear, vsys.wMonth, vsys.wDay);
      DecodeTime(dt, vsys.wHour, vsys.wMinute, vsys.wSecond, vsys.wMilliseconds);
      if ComboBox1.ItemIndex = 0 then SetLocalTime(vsys)
      else SetSystemTime(vsys);
    end;
    ShowMessage(IntToStr(server_calc_ticks) + ' ' + buff + ' ' + IntToStr(add_ticks));
  end else begin
    ShowMessage('Error in string: ' + buff);
  end;
end;

procedure TForm1.clntsckt1Error(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ShowMessage('Error to connect to server.');
  btn1.Enabled := True;
  clntsckt1Disconnect(Sender, Socket);
end;

procedure TForm1.clntsckt1Connect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  btn1.Enabled := True;
  btn2.Enabled := True;
  btn1.Caption := 'Disconnect';
end;

procedure TForm1.clntsckt1Connecting(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  btn1.Caption := 'Connecting...';
  edt1.Enabled := False;
  edt2.Enabled := False;
end;

procedure TForm1.clntsckt1Disconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  btn1.Caption := 'Connect';
  edt1.Enabled := True;
  edt2.Enabled := True;
  btn2.Enabled := False;
end;

end.
