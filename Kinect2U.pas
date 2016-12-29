unit Kinect2U;

interface

uses
  Windows, Kinect2DLL, Graphics, SysUtils, Classes, IniFiles, Global;

type
  TByteTable = array[0..High(TDepthFrameData)] of Byte;

  TKinect2 = class(TObject)
  private
    ByteTable : TByteTable;

    FrameRateFrame : Integer;
    RGBOffset      : Integer;

    XTable : array[0..DEPTH_W-1] of Word;
    YTable : array[0..DEPTH_H-1] of Word;

    procedure BuildByteTable;

    procedure SetMinDepth(V:TDepthFrameData);
    procedure SetMaxDepth(V:TDepthFrameData);
    function DefaultCropWindow: TCropWindow;

  public
    FMinDepth : TDepthFrameData;
    FMaxDepth : TDepthFrameData;

    DepthBmp : TBitmap;
    SmallBmp : TBitmap;

    DllLoaded : Boolean;
    Ready     : Boolean;

    FrameCount  : Integer;
    MeasuredFPS : Single;
    LastFrameRateTime : DWord;

    CropWindow : TCropWindow;

    ClosestD : Single;

    DepthData : PDepthFrameData;

    property MinDepth:TDepthFrameData read FMinDepth write SetMinDepth;
    property MaxDepth:TDepthFrameData read FMaxDepth write SetMaxDepth;

    constructor Create;
    destructor Destroy; override;

    function DLLFileFound:Boolean;
    function DLLVersion:String;

    procedure StartUp;
    procedure ShutDown;

    function  AbleToGetNewFrame:Boolean;
    procedure DoneFrame;

    function  DepthAtXY(X,Y:Integer):Integer;
    
    procedure DrawDepthBmp;
    procedure MeasureFrameRate;
    procedure CycleRGBOffset;

    procedure LoadFromIniFile(IniFile:TIniFile);
    procedure SaveToIniFile(IniFile:TIniFile);

    procedure SetRGBOffset(V:Integer);
    procedure DrawCropWindow(Bmp: TBitmap);

    procedure InitForTracking;

  end;

var
  Kinect2 : TKinect2;

implementation

uses
  BmpUtils;

const
  FrameRateAverages  = 10;

constructor TKinect2.Create;
begin
  DepthBmp:=TBitmap.Create;
  DepthBmp.Width:=DEPTH_W;
  DepthBmp.Height:=DEPTH_H;
  DepthBmp.PixelFormat:=pf24Bit;
  ClearBmp(DepthBmp,clBlack);

  SmallBmp:=TBitmap.Create;
  SmallBmp.PixelFormat:=pf24Bit;

  DllLoaded:=False;
  Ready:=False;

  FrameCount:=0;
  FrameRateFrame:=0;

  MeasuredFPS:=0;
  LastFrameRateTime:=GetTickCount;
end;

destructor TKinect2.Destroy;
begin
  if Assigned(DepthBmp) then DepthBmp.Free;
  if Assigned(SmallBmp) then SmallBmp.Free;
end;

function TKinect2.DLLVersion:String;
begin
  Result:=KinectVersionString;
end;

procedure TKinect2.InitForTracking;
begin
end;

procedure TKinect2.StartUp;
begin
  if AbleToLoadKinectLibrary then begin
    DllLoaded:=True;
    Ready:=AbleToStartUpKinect2;
  end;
end;

procedure TKinect2.ShutDown;
begin
  if Ready then begin
    ShutDownKinect2;
    Ready:=False;
  end;

  UnloadKinectLibrary;
end;

procedure TKinect2.MeasureFrameRate;
var
  Time    : DWord;
  Elapsed : Single;
begin
  Inc(FrameCount);

// average it out a bit so it's readable
  if (FrameCount-FrameRateFrame)>=FrameRateAverages then begin
    Time:=GetTickCount;
    Elapsed:=(Time-LastFrameRateTime)/1000;
    if Elapsed=0 then MeasuredFPS:=999
    else MeasuredFPS:=FrameRateAverages/Elapsed;

    LastFrameRateTime:=Time;
    FrameRateFrame:=FrameCount;
  end;
end;

function TKinect2.AbleToGetNewFrame: Boolean;
begin
  DepthData:=LatestDepthFrameData;

  if Assigned(DepthData) then begin
    DrawDepthBmp;
    MeasureFrameRate;
    Result:=True;
  end
  else Result:=False;
end;

procedure TKinect2.DoneFrame;
begin
  DoneProcessingFrame;
end;

procedure TKinect2.SetMinDepth(V:TDepthFrameData);
begin
  FMinDepth:=V;
  BuildByteTable;
end;

procedure TKinect2.SetMaxDepth(V:TDepthFrameData);
begin
  FMaxDepth:=V;
  BuildByteTable;
end;

procedure TKinect2.BuildByteTable;
var
  I : TDepthFrameData;
  F : Single;
  V : Byte;
begin
  for I:=0 to High(TDepthFrameData) do begin
    if I<FMinDepth then V:=0
    else if I>FMaxDepth then V:=0
    else if FMaxDepth=FMinDepth then V:=0
    else begin
      F:=(I-FMinDepth)/(FMaxDepth-FMinDepth);
      V:=Round(F*255);
    end;
    ByteTable[I]:=V;
  end;
end;

function TKinect2.DLLFileFound:Boolean;
var
  FileName : String;
begin
  FileName:=FullDLLName;
  Result:=FileExists(FileName);
end;

function TKinect2.DepthAtXY(X,Y:Integer):Integer;
var
  DepthPtr  : PWord;
  XM,Offset : Integer;
begin
  if Assigned(DepthData) then begin
    DepthPtr:=DepthData;

// X is mirrored
    XM:=(DEPTH_W-1)-X;

// find the offset
    Offset:=Y*DEPTH_W+X;//M;

// read the value - in mm - convert to metres
    Inc(DepthPtr,Offset);
    Result:=DepthPtr^;
  end
  else Result:=0;
end;

procedure TKinect2.DrawDepthBmp;
var
  Data  : PDepthFrameData;
  Line  : PByteArray;
  X,Y   : Integer;
  Xm,Ym : Integer;
begin
  ClosestD:=-1;

  Data:=DepthData;
  for Y:=0 to DEPTH_H-1 do begin
    Line:=DepthBmp.ScanLine[Y];
    Ym:=YTable[Y];
    for X:=0 to DEPTH_W-1 do begin
      Line^[X*3+RGBOffset]:=ByteTable[Data^];

      if (Data^>=MinDepth) and (Data^<=MaxDepth) then begin
        if (ClosestD<0) or (Data^<ClosestD) then ClosestD:=Data^;
      end;
      Inc(Data);
    end;
  end;
end;

procedure TKinect2.CycleRGBOffset;
begin
//  ClearBmp(DepthBmp,clBlack);
  if RGBOffset<2 then Inc(RGBOffset)
  else RGBOffset:=0;
end;

function TKinect2.DefaultCropWindow:TCropWindow;
begin
  with Result do begin
    W:=Round(DEPTH_W*0.70);
    H:=Round(DEPTH_H*0.70);
    X:=(DEPTH_W-W) div 2;
    Y:=(DEPTH_H-1)-H;
  end;
end;

procedure TKinect2.LoadFromIniFile(IniFile:TIniFile);
var
  DefaultWindow : TCropWindow;
begin
  FMinDepth:=IniFile.ReadInteger('Kinect','MinDepth',1);
  FMaxDepth:=IniFile.ReadInteger('Kinect','MaxDepth',1000);

  DefaultWindow:=DefaultCropWindow;

  CropWindow.X:=IniFile.ReadInteger('Kinect','CropX',DefaultWindow.X);
  CropWindow.Y:=IniFile.ReadInteger('Kinect','CropY',DefaultWindow.Y);
  CropWindow.W:=IniFile.ReadInteger('Kinect','CropW',DefaultWindow.W);
  CropWindow.H:=IniFile.ReadInteger('Kinect','CropH',DefaultWindow.H);

  BuildByteTable;
//  BuildXYTables;
end;

procedure TKinect2.SaveToIniFile(IniFile:TIniFile);
begin
  IniFile.WriteInteger('Kinect','MinDepth',FMinDepth);
  IniFile.WriteInteger('Kinect','MaxDepth',FMaxDepth);

  IniFile.WriteInteger('Kinect','CropX',CropWindow.X);
  IniFile.WriteInteger('Kinect','CropY',CropWindow.Y);
  IniFile.WriteInteger('Kinect','CropW',CropWindow.W);
  IniFile.WriteInteger('Kinect','CropH',CropWindow.H);
end;

procedure TKinect2.SetRGBOffset(V:Integer);
begin
  RGBOffset:=V;
  ClearBmp(DepthBmp,clBlack);
end;

procedure TKinect2.DrawCropWindow(Bmp:TBitmap);
begin
  Bmp.Canvas.Brush.Style:=bsClear;
  Bmp.Canvas.Pen.Color:=clGreen;
  Bmp.Canvas.Pen.Style:=psSolid;
  with CropWindow do Bmp.Canvas.Rectangle(X,Y,X+W,Y+H);
end;

end.


