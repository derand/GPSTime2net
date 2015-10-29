program gpstime2net_server;

uses
  Forms,
  main in 'main.pas' {Form1},
  MySocketThread in 'MySocketThread.pas',
  Logger in '..\libs\Logger.pas',
  MyCommon in '..\libs\MyCommon.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
