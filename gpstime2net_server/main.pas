unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AfComPort, DateUtils, Sockets,
  ScktComp, MySocketThread, AfDataDispatcher, Logger, MyCommon, ExtCtrls;

type
  TForm1 = class(TForm)
    AfComPort1: TAfComPort;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Button1: TButton;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Button2: TButton;
    srvrsckt1: TServerSocket;
    Label10: TLabel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure AfComPort1DataRecived(Sender: TObject; Count: Integer);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure srvrsckt1GetThread(Sender: TObject;
      ClientSocket: TServerClientWinSocket;
      var SocketThread: TServerClientThread);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure srvrsckt1ThreadStart(Sender: TObject;
      Thread: TServerClientThread);
    procedure srvrsckt1ThreadEnd(Sender: TObject;
      Thread: TServerClientThread);
  private
    { Private declarations }
    data_buffer: WideString;
    i: Integer;

    sync_flag: Boolean;
    sync_ticks: DWord;
    sync_time: TDateTime;

    last_ticks: DWord;
    date: TDateTime;
    syncing: Boolean;

    //
    active: string;
    diff1, diff2: Int64;
    calc_type: byte;
    sattelite_count: byte;
    tm_str1, tm_str2: string;

    logger: TLogger;

    function check_buffer: Boolean;
    function LocalDateTimeFromUTCDateTime(const UTCDateTime: TDateTime): TDateTime;
  public
    { Public declarations }
    function getLocalDateTime(): TDateTime;
    function getGPSDateTime(): TDateTime;
    function getLogger(): Tlogger;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  logger := TLogger.Create(LogDebug, '../', 's');
  logger.msg(LogInfo, 'Client started(' + IntToStr(Ord(logger.getLogLevel)) + ')');

  sync_flag := False;
  syncing := False;
  AfComPort1.Open;
// Memo1.lines.Add(AfComPort1.SettingsStr);
  i := 0;
  data_buffer := '$';
  sync_time := Now;
  sync_ticks := GetTickCount;

  calc_type := 0;
  sattelite_count := 0;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  logger.Free;
end;

function TForm1.check_buffer: Boolean;
var
  lines, components: TStrings;
  j: Integer;
  //gps_format: TFormatSettings;
  //y,m,d,h,n,s,ms: Word;
  comp: TDateTime;
  vsys : _SYSTEMTIME;
  date_idx: Byte;
  curr_ttime: TDateTime;
  ticks: Int64;
begin
  lines := TStringList.Create;
  //gps_format.ShortDateFormat := 'ddmmyy';
  //gps_format.LongTimeFormat := 'hh24mmss.zz';
  //gps_format.DateSeparator := '';
  //gps_format.TimeSeparator := '';
  ticks := GetTickCount;
  try
    ExtractStrings(['$'], [], PChar(String(data_buffer)), lines);
    if lines.Count > 2 then
    begin
      Result := True;
      for j:=0 to lines.Count-2 do
      begin
        components := TStringList.Create;
        try
          ExtractStrings([','], [], PChar(lines[j]), components);
          if components.Count > 8 then
          begin
            date_idx := 7;
            if (components.Count > 9) and (length(components[9]) = 6) then
              date_idx := 9;
            if (CompareStr('GPRMC', components[0]) = 0) and (length(components[date_idx]) = 6) and (length(components[1]) = 9) then
            begin
              syncing := True;
              last_ticks := ticks;
              vsys.wYear := StrToInt(copy(components[date_idx], 5, 2))+2000;
              vsys.wMonth := StrToInt(copy(components[date_idx], 3, 2));
              vsys.wDay := StrToInt(copy(components[date_idx], 1, 2));
              vsys.wHour := StrToInt(copy(components[1], 1, 2));
              vsys.wMinute := StrToInt(copy(components[1], 3, 2));
              vsys.wSecond := StrToInt(copy(components[1], 5, 2));
              vsys.wMilliseconds := StrToInt(copy(components[1], 8, 2))*10;
              if sync_flag then
              begin
                //SetSystemTime(vsys);
                SetSystemTimeWithDiff(vsys, GetTickCount - ticks, TTSystem);
                sync_flag := False;
                sync_ticks := GetTickCount;
                sync_time := Now;
                //sync_ticks := last_ticks;
                comp := sync_time;
                logger.msg(LogInfo, 'Time synchronized');
              end else begin
                comp := Now;
              end;
              date := EncodeDateTime(vsys.wYear, vsys.wMonth, vsys.wDay, vsys.wHour, vsys.wMinute, vsys.wSecond, vsys.wMilliseconds);
              syncing := False;
              curr_ttime := IncMillisecond(sync_time, last_ticks-sync_ticks);
              Label2.Caption := FormatDateTime('dd/mm/yyyy hh:nn:ss.zzz', date);
              Label4.Caption := FormatDateTime('dd/mm/yyyy hh:nn:ss.zzz', comp);
              diff1 := MilliSecondsBetween(LocalDateTimeFromUTCDateTime(date), comp);
              diff2 := MilliSecondsBetween(LocalDateTimeFromUTCDateTime(date), curr_ttime);
              Label6.Caption := IntToStr(diff1) + ' ms';
              Label8.Caption := IntToStr(diff2) + ' ms';
              Label7.Caption := lines[j];
              active := components[2];
              tm_str1 := components[1];
            end else  if (CompareStr('GPGGA', components[0]) = 0) then
            begin
              calc_type := StrToInt(components[6]);
              sattelite_count := StrToInt(components[7]);
              tm_str2 := components[1];
              logger.msg(LogDebug, active + IntToStr(calc_type) + ' ' + IntToStr(diff1) + '/' + IntToStr(diff2) + ' sc:' + IntToStr(sattelite_count) + ' ' + tm_str1 + '/' + tm_str2);
            end;
          end;
        finally
          components.Free;
          syncing := False;
        end;
        logger.msg(LogVerbose, lines[j]);
        //Memo1.Lines.Add(lines[j]);
      end;

      data_buffer := lines[lines.Count-1]
    end else
      Result := False
  finally
    lines.Free;
  end;
end;

function TForm1.LocalDateTimeFromUTCDateTime(const UTCDateTime: TDateTime): TDateTime;
var
  LocalSystemTime: TSystemTime;
  UTCSystemTime: TSystemTime;
  LocalFileTime: TFileTime;
  UTCFileTime: TFileTime;
begin
  DateTimeToSystemTime(UTCDateTime, UTCSystemTime);
  SystemTimeToFileTime(UTCSystemTime, UTCFileTime);
  if FileTimeToLocalFileTime(UTCFileTime, LocalFileTime) 
  and FileTimeToSystemTime(LocalFileTime, LocalSystemTime) then begin
    Result := SystemTimeToDateTime(LocalSystemTime);
  end else begin
    Result := UTCDateTime;  // Default to UTC if any conversion function fails.
  end;
end;

function TForm1.getLocalDateTime(): TDateTime;
//var
//  curr_ttime: TDateTime;
begin
//  curr_ttime := IncMillisecond(sync_time, GetTickCount-sync_ticks);
//  Result := curr_ttime;
  Result := Now;
end;

function TForm1.getGPSDateTime(): TDateTime;
begin
  while syncing do
    sleep(5);
  Result := IncMillisecond(date, GetTickCount()-last_ticks);
end;

function TForm1.getLogger(): TLogger;
begin
  Result := logger;
end;

procedure TForm1.AfComPort1DataRecived(Sender: TObject; Count: Integer);
var
  data: String;
begin
  data := AfComPort1.ReadString;
  data_buffer := data_buffer + data;

  check_buffer();

  i := i + 1;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  sync_flag := True;
  logger.msg(LogDebug, 'Waiting to sync...');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if srvrsckt1.Active then
  begin
    srvrsckt1.Active := False;
    Button2.Caption := 'Start server';
  end else begin
    srvrsckt1.Active := True;
    Button2.Caption := 'Stop server';
  end;
end;

procedure TForm1.srvrsckt1GetThread(Sender: TObject;
  ClientSocket: TServerClientWinSocket;
  var SocketThread: TServerClientThread);
begin
  SocketThread :=  TMySocketThread.Create(False, ClientSocket);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i: Integer;
begin
  for i:=0 to srvrsckt1.Socket.ActiveConnections-1 do
    srvrsckt1.Socket.Connections[i].SendText('update');
end;

procedure TForm1.srvrsckt1ThreadStart(Sender: TObject;
  Thread: TServerClientThread);
begin
  logger.msg(LogInfo, 'Client ' + Thread.ClientSocket.RemoteAddress + ' connected');
  Label10.Caption := 'Connections: ' + IntToStr(srvrsckt1.Socket.ActiveConnections);
end;

procedure TForm1.srvrsckt1ThreadEnd(Sender: TObject;
  Thread: TServerClientThread);
begin
  Label10.Caption := 'Connections: ' + IntToStr(srvrsckt1.Socket.ActiveConnections);
end;

end.
