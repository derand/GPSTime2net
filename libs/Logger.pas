unit Logger;

interface

uses SysUtils, TypInfo;

type
  ELogLevel = (LogError, LogInfo, LogDebug, LogVerbose);

  TLogger = class(TObject)
  private
    fn: String;
    log: TextFile;
    _log_level: ELogLevel;

  public
    constructor Create; overload;
    constructor Create(log_level: ELogLevel; path: string; file_suffix: String); overload;
    procedure msg(log_level: ELogLevel; msg: String);
  end;

implementation

var
  LogLevel_strings: array[0..3] of string = ('error', 'info', 'debug', 'verbose');

constructor TLogger.Create();
begin
  Create(LogInfo, '', '');
end;

constructor TLogger.Create(log_level: ELogLevel; path: string; file_suffix: String);
begin
  inherited Create;

  if Length(file_suffix) > 0 then
  begin
    fn := FormatDateTime('yyyy_mm_dd', Now) + file_suffix + '.log';
  end else begin
    fn := FormatDateTime('yyyy_mm_dd', Now) + '.log';
  end;
  if Length(path) > 0 then
  begin
    fn := path + fn;
  end;

  _log_level := log_level;

  if FileExists(fn) then
  begin
    AssignFile(log, fn);
    Append(log);
    Writeln(log, '');
    Flush(log);
  end else begin
    AssignFile(log, fn);
    Rewrite(log);
    //Append(log);
  end;
end;

procedure TLogger.msg(log_level: ELogLevel; msg: String);
var
  str: string;
begin
  if log_level <= _log_level then
  begin
    //Writeln(log, DateTimeToStr(Now) + '[' + LogLevel_strings[Ord(log_level)] + ']:' + Chr(9) +  '' + msg);
    Writeln(log, FormatDateTime('dd.mm.yyyy hh:nn:ss.zzz', Now) + '[' + LogLevel_strings[Ord(log_level)] + ']:' + Chr(9) +  '' + msg);
    Flush(log);
  end;
end;

end.
