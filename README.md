# DelphiKinect2Depth
Delphi implementation of the Kinect2 depth stream

Using the original Kinect under windows was easy with delphi. Because the DLL was C, it was a fairly simple matter to make translate the .h file into .pas.

Unfortunately, the Kinect2 DLL includes objects and such which makes this more difficult. Another way would be to use the provided assemblies, but that's also a bit of a pain.

So I wrote a DLL in QT that goes in between the Kinect20.lib file and Delphi.

This implementation only provides access to the depth stream, but I do have another project and DLL that hasn't been released that accesses the color camera, IR camera, and body data.

An exe is included. Just run Depth.exe making sure its in the same folder as Kinect2DLL.dll

A screen shot, Screen.png is included. You can set the min and max range of the depth. The pixels are shaded blue relative to their depth between these ranges. There is also a readout of the depth where the mouse cursor is.

The source for the DLL can be found at:

https://github.com/ConroyBadger/Kinect2DLL






