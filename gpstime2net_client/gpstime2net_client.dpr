program gpstime2net_client;

uses
  Forms,
  main in 'main.pas' {Form1},
  Logger in '..\libs\Logger.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
