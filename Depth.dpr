program Depth;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainFrm},
  Kinect2Dll in 'Kinect2Dll.pas',
  Kinect2U in 'Kinect2U.pas',
  Global in 'Global.pas',
  BmpUtils in 'BmpUtils.pas',
  Routines in 'Routines.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
