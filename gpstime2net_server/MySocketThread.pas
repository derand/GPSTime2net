unit MySocketThread;

interface

uses ScktComp, Dialogs, Windows, SysUtils;

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
        Terminate;
        Exit;
      end;
      SetLength(buff, l);
      ClientSocket.ReceiveBuf(buff[1], l);
      ticks := GetTickCount;
      if (CompareStr(buff, 't') = 0) or (CompareStr(buff, 'time') = 0) then
      begin
        dt := Form1.getLocalDateTime();
        buff := FormatDateTime('dd/mm/yyyy hh:nn:ss.zzz', dt);
        buff := buff + '#' + IntToStr(GetTickCount-ticks);
        ClientSocket.SendText(buff);
      end else if (CompareStr(buff, 'g') = 0) or (CompareStr(buff, 'gps') = 0) then
      begin
        dt := Form1.getGPSDateTime();
        buff := FormatDateTime('dd/mm/yyyy hh:nn:ss.zzz', dt);
        buff := buff + '#' + IntToStr(GetTickCount-ticks);
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
  ClientSocket.Close;
  Terminate;
end;

end.
