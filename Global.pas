unit Global;

interface

uses
  Windows, Graphics, Kinect2DLL;

const
  Debugging = False;//True;
  VersionStr = 'v1.00';

  COLOR_W = 1280;
  COLOR_H = 960;

  MaxImageW = COLOR_W; // 1280;
  MaxImageH = COLOR_H; // 960;

  TrackW = COLOR_W;
  TrackH = COLOR_H;

  MaxBufferSize = MaxImageW*MaxImageH*3;

  COLOR_RECT : TRect = (Left:0;Top:0;Right:COLOR_W-1;Bottom:COLOR_H-1);

type
  TCropWindow = record
    X,Y,W,H : Integer;
  end;

  TBGRPixel = record
    B,G,R : Byte;
  end;
  PBGRPixel = ^TBGRPixel;

  TBGRAPixel = record
    B,G,R,A : Byte;
  end;
  PBGRAPixel = ^TBGRAPixel;

  TTextureData = array[1..MaxImageW*MaxImageH*3] of Byte;

  TPixelPt = record
    X,Y : Integer;
  end;

  TRunMode = (rmRunning,rmCamera,rmTextures,rmOldTextures);

//  TDisplayMode = dm

  TDrawOption = (doStrips,doBlobs,doBlobOutlines,doPerimeter,doBands);
  TDrawOptions = Set of TDrawOption;

  TDrawWindow = record
    X,Y : Integer;
    W,H : Integer;
  end;

  TRGBRecord = record
    Red   : Byte;
    Green : Byte;
    Blue  : Byte;
  end;
  TPalette = array[0..255] of TRGBRecord;

//  TAutoBackGndRecord = record
//    Enabled : Boolean;
//    Period  : DWord;
//    Armed   : Boolean;
//    ArmTime : DWord;
//  end;

  TFolderName = String[100];

  TPoint2D = record
    X,Y : Single;
  end;

  TPoint3D = record
    X,Y,Z : Single;
  end;

  TRay = record
    Base   : TPoint3D;
    Vector : TPoint3D;
  end;

  TPlane = record
    Point    : array[1..4] of TPoint3D;
    Finite   : Boolean;
    Nx,Ny,Nz : Single;
    A,B,C,D  : Single; // coefficients
  end;

  TFontName = String[32];

  TDisplayFont = record  // 58
    Name     : TFontName;
    Style    : TFontStyles;
    MinSize  : Integer;
    MaxSize  : Integer;
    Reserved : array[1..16] of Byte;
  end;

  TPose = record
    X,Y,Z    : Single;
    Rx,Ry,Rz : Single;
  end;

  TKInfo = record
    K1,K2 : Single;
    Px,Py : Single;
    Skew  : Single;
    D     : array[1..4] of Single;
  end;

  TCameraBuffer = array[1..MaxBufferSize] of Byte;

  TDisplayMode = (dmFullScreen,dmWindowed);

  TDisplay = record
    Mode : TDisplayMode;
    X,Y  : Integer;
    W,H  : Integer;
  end;

var
  DrawOptions    : TDrawOptions;
  RunMode        : TRunMode;
  SobelThreshold : Integer = 15000;

  RunW : Integer = 1280;
  RunH : Integer = 800;

  QuadW : Integer = 1280;
  QuadH : Integer = 800;

  Display : TDisplay;

implementation

end.


