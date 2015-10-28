program gpstime2net_server;

uses
  Forms,
  main in 'main.pas' {Form1},
  MySocketThread in 'MySocketThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
