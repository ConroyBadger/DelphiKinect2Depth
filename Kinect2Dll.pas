unit Kinect2Dll;

interface

uses
  Windows, SysUtils;

type
  TDepthFrameData = Word;
  PDepthFrameData = PWord;

function KinectVersionString:String;

function AbleToLoadKinectLibrary:Boolean;
procedure UnloadKinectLibrary;

function  AbleToStartUpKinect2:Boolean;
procedure ShutDownKinect2;

function LatestDepthFrameData:PDepthFrameData;
procedure DoneProcessingFrame;

function FullDLLName:String;

const
// for working with the DLL - when its good copy it to local folder
// and axe the path
//  KINECT2_DLL_NAME = 'C:\Kinect\2.0\QT\Kinect2DLL\debug\Kinect2DLL.dll';
//  KINECT2_DLL_NAME = 'C:\Qt\Projects\Kinect2DLL\debug\Kinect2DLL.dll';
//  KINECT2_DLL_NAME = 'Kinect2DLL.dll';

//  KINECT2_DLL_NAME = 'C:\Qt\Projects\TestDLL\debug\TestDLL.dll';

  KINECT2_DLL_NAME = 'Kinect2DLL.dll';


  DEPTH_W = 512;
  DEPTH_H = 424;

implementation

uses
  Routines, Dialogs;

type
  TGetVersion = function:Integer; stdcall; // yes it'sok  just an integer :)

  TAbleToInitialize = function:Boolean; stdcall;

  TGetFrame = function:PDepthFrameData; stdcall;

  TDoneFrame = procedure; stdcall;

  TShutDown = procedure; stdcall;

var
  HLibrary : HModule = 0;

  GetVersion       : TGetVersion = nil;
  AbleToInitialize : TAbleToInitialize = nil;
  GetFrame         : TGetFrame = nil;
  DoneFrame        : TDoneFrame = nil;
  ShutDown         : TShutDown = nil;

function FullDLLName:String;
begin
  Result:=Path+KINECT2_DLL_NAME;
end;

function KinectVersionString:String;
var
  V : Integer;
begin
  if HLibrary=0 then Result:='???'
  else begin
    V:=getVersion;
    Result:=IntToStr(V);
  end;
end;

procedure ShowError;
var
  Err   : Cardinal;
  Flags : Cardinal;
  Txt   : String[255];
begin
  Err:=GetLastError;

  Flags:=FORMAT_MESSAGE_ALLOCATE_BUFFER or
         FORMAT_MESSAGE_FROM_SYSTEM or
         FORMAT_MESSAGE_IGNORE_INSERTS;

  FormatMessage(Flags,nil,Err,MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                PChar(@Txt[1]),0,nil);
  ShowMessage(Txt);
end;

function AbleToLoadKinectLibrary:Boolean;
var
  FileName : String;
begin
  Result:=False;
  if HLibrary<>0 then Exit;

  FileName:=FullDLLName;
  if not FileExists(FileName) then Exit;

  HLibrary:=LoadLibrary(PChar(FileName));
  if HLibrary=0 then begin
    ShowError;
    Exit;
  end;

  GetVersion:=GetProcAddress(HLibrary,'getVersion');
  if not Assigned(GetVersion) then Exit;

  AbleToInitialize:=GetProcAddress(HLibrary,'ableToInitialize');
  if not Assigned(AbleToInitialize) then Exit;

  GetFrame:=GetProcAddress(HLibrary,'getFrame');
  if not Assigned(GetFrame) then Exit;

  DoneFrame:=GetProcAddress(HLibrary,'doneFrame');
  if not Assigned(DoneFrame) then Exit;

  ShutDown:=GetProcAddress(HLibrary,'shutDown');
  if not Assigned(ShutDown) then Exit;

  Result:=True;
end;

procedure UnloadKinectLibrary;
begin
  if HLibrary=0 then Exit;

  GetVersion:=nil;
  AbleToInitialize:=nil;
  GetFrame:=nil;
  DoneFrame:=nil;
  ShutDown:=nil;

  FreeLibrary(HLibrary);

  HLibrary:=0;
end;

function AbleToStartUpKinect2:Boolean;
begin
  Result:=AbleToInitialize;
end;

procedure ShutDownKinect2;
begin
  ShutDown;
end;

function LatestDepthFrameData:PDepthFrameData;
begin
  Result:=GetFrame;
end;

// this needs to be called even if getFrame() returns NULL as
// kinect->ableToUpdate() can fail even if a depthFrame is acquired
// kinect->freeDepthFrame checks for NULL so it's safe
procedure DoneProcessingFrame;
begin
  DoneFrame;
end;

end.
