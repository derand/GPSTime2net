unit MySocketThread;

interface

uses ScktComp, Dialogs, Windows, SysUtils, StrUtils, Logger;

type
  TMySocketThread = class(TServerClientThread)
  protected
    procedure ClientExecute; override;
  private
  public
  end;

implementation

uses main;

procedure TMySocketThread.ClientExecute;
var
  stream: TWinSocketStream;
  ip, buff: string;
  l: Integer;
  ticks: DWord;
  dt: TDateTime;
  prms: string;
begin
  ip := ClientSocket.RemoteAddress;
  try
    stream := TWinSocketStream.Create(ClientSocket, 10000);
  except
    ClientSocket.Close;
    Terminate;
    Exit;
  end;
  while ClientSocket.Connected and not Terminated do
  begin
    if stream.WaitForData(1) then
    begin
      l := ClientSocket.ReceiveLength;
      if (l > 65535) or (l = 0) then
      begin
        buff := '';
        if l <> 0 then ClientSocket.Close;
        Form1.getLogger.msg(LogInfo, 'Client ' + ClientSocket.RemoteAddress + ' disconnected');
        Terminate;
        Exit;
      end;
      SetLength(buff, l);
      ClientSocket.ReceiveBuf(buff[1], l);
      ticks := GetTickCount;
      Form1.getLogger.msg(LogVerbose, 'Recive: ''' + buff+ ''' from client ' + ClientSocket.RemoteAddress);
      l := AnsiPos('#', buff);
      if l > 0 then
      begin
        if (l+1) < Length(buff) then
          prms := Copy(buff, l+1, Length(buff)-l);
        SetLength(buff, l-1);
      end else
        prms := '';
      if (CompareStr(buff, 'l') = 0) or (CompareStr(buff, 'local') = 0) then
      begin
        dt := Form1.getLocalDateTime();
        buff := 'L' + FormatDateTime('dd/mm/yyyy hh:nn:ss.zzz', dt);
        buff := buff + '#' + prms + '#';
        buff := buff + IntToStr(GetTickCount-ticks);
        ClientSocket.SendText(buff);
      end else if (CompareStr(buff, 'g') = 0) or (CompareStr(buff, 'gps') = 0) then
      begin
        dt := Form1.getGPSDateTime();
        buff := 'G' + FormatDateTime('dd/mm/yyyy hh:nn:ss.zzz', dt);
        buff := buff + '#' + prms + '#';
        buff := buff + IntToStr(GetTickCount-ticks);
        ClientSocket.SendText(buff);
      end else if (CompareStr(buff, 'p') = 0) or (CompareStr(buff, 'ping') = 0) then
      begin
        ClientSocket.SendText('pong');
      end;
      //ClientSocket.SendText('asd');
      //Form1.Button2.Caption := buff;
      //ShowMessage(buff);
    end;
  end;
  Form1.getLogger.msg(LogInfo, 'Client ' + ClientSocket.RemoteAddress + ' disconnected');
  ClientSocket.Close;
  Terminate;
end;

end.
