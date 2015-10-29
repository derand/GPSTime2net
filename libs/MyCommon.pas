unit MyCommon;

interface

uses Windows, DateUtils, SysUtils;

type
  ETimeType = (TTLocal, TTSystem);

procedure SetSystemTimeWithDiff(var vsys: _SYSTEMTIME; const add_ticks: Int64; const timetype: ETimeType);

implementation

procedure SetSystemTimeWithDiff(var vsys: _SYSTEMTIME; const add_ticks: Int64; const timetype: ETimeType);
var
  dt: TDateTime;
  tmp: Int64;
begin
  if add_ticks <> 0 then
  begin
    tmp := GetTickCount;
    dt := EncodeDateTime(vsys.wYear, vsys.wMonth, vsys.wDay, vsys.wHour, vsys.wMinute, vsys.wSecond, vsys.wMilliseconds);
    dt := IncMillisecond(dt, add_ticks + (GetTickCount - tmp));
    DecodeDate(dt, vsys.wYear, vsys.wMonth, vsys.wDay);
    DecodeTime(dt, vsys.wHour, vsys.wMinute, vsys.wSecond, vsys.wMilliseconds);
  end;
  if timetype = TTLocal then SetLocalTime(vsys)
  else SetSystemTime(vsys);
end;

end.
