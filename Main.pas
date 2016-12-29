unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, UnitLCD,
  USpin, Vcl.StdCtrls, Vcl.Samples.Spin;

type
  TMainFrm = class(TForm)
    StatusBar: TStatusBar;
    KinectTimer: TTimer;
    PaintBox: TPaintBox;
    Panel4: TPanel;
    Label7: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label1: TLabel;
    MinDSB: TScrollBar;
    MinDLbl: TLabel;
    MaxDSB: TScrollBar;
    MaxDLbl: TLabel;
    DepthLbl: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure KinectTimerTimer(Sender: TObject);
    procedure MinDSBChange(Sender: TObject);
    procedure MaxDSBChange(Sender: TObject);

  private
    Bmp : TBitmap;
    procedure ShowMouseDepth;
    function MetreStr(MM: Integer): String;
    procedure ShowMaxD;
    procedure ShowMinD;

  public
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

uses
  Kinect2U, Kinect2DLL, BmpUtils;

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  Bmp:=CreateBmpForPaintBox(PaintBox);

// kinect
  Kinect2:=TKinect2.Create;

    // see the the DLL file is found
  if Kinect2.DLLFileFound then begin

// try to load the DLL and start the Kinect
    Kinect2.StartUp;
    if Kinect2.DllLoaded then begin
      StatusBar.Panels[0].Text:='Library version #'+Kinect2.DLLVersion+' loaded';

// all is well
      if Kinect2.Ready then begin
        StatusBar.Panels[1].Text:='SDK ready';
        KinectTimer.Enabled:=True;
      end

// all is not well
      else StatusBar.Panels[1].Text:='Kinect not ready';
    end
    else StatusBar.Panels[0].Text:='Library not loaded';
  end
  else StatusBar.Panels[0].Text:=KINECT2_DLL_NAME+' not found';

  Kinect2.MinDepth:=MinDSB.Position;
  Kinect2.MaxDepth:=MaxDSB.Position;

  ShowMinD;
  ShowMaxD;
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
  if Assigned(Kinect2) then Kinect2.Free;
end;

procedure TMainFrm.KinectTimerTimer(Sender: TObject);
begin
  if Kinect2.AbleToGetNewFrame then begin
    Bmp.Canvas.Draw(0,0,Kinect2.DepthBmp);
    Kinect2.DrawCropWindow(Bmp);
    ShowFrameRateOnBmp(Bmp,Kinect2.MeasuredFPS);

    PaintBox.Canvas.Draw(0,0,Bmp);
  end;
  ShowMouseDepth;
  Kinect2.DoneFrame;
end;

procedure TMainFrm.MinDSBChange(Sender: TObject);
begin
  Kinect2.MinDepth:=MinDSB.Position;
  ShowMinD;
end;

procedure TMainFrm.MaxDSBChange(Sender: TObject);
begin
  Kinect2.MaxDepth:=MaxDSB.Position;
  ShowMaxD;
end;

procedure TMainFrm.ShowMouseDepth;
var
  MousePt    : TPoint;
  PixelColor : TColor;
  XF,YF      : Single;
begin
  GetCursorPos(MousePt);
  MousePt:=PaintBox.ScreenToClient(MousePt);
  if (MousePt.X>=0) and (MousePt.X<DEPTH_W) and
     (MousePt.Y>=0) and (MousePt.Y<DEPTH_H) then
  begin
    DepthLbl.Caption:=MetreStr(Kinect2.DepthAtXY(MousePt.X,MousePt.Y));
  end
  else DepthLbl.Caption:='--.--';
end;

function TMainFrm.MetreStr(MM:Integer):String;
begin
  Result:=FloatToStrF(MM/1000,ffFixed,9,2);
end;

procedure TMainFrm.ShowMinD;
begin
  MinDLbl.Caption:=MetreStr(MinDSB.Position);
end;

procedure TMainFrm.ShowMaxD;
begin
  MaxDLbl.Caption:=MetreStr(MaxDSB.Position);
end;

end.
