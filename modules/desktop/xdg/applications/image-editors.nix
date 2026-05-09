{
  flake.modules.homeManager.xdgApplications = {lib, ...}: let
    inherit
      (lib.self)
      # keep-sorted start
      mimeAppDefaults
      mimeAppEntries
      # keep-sorted end
      ;
  in {
    xdg.mimeApps.defaultApplications = mimeAppDefaults (
      # keep-sorted start block=yes
      (mimeAppEntries "image" "gimp.desktop" [
        # keep-sorted start
        "jp2"
        "openraster"
        "vnd.adobe.photoshop"
        "vnd.wap.wbmp"
        "vnd.zbrush.pcx"
        "wmf"
        "x-icns"
        "x-ilbm"
        "x-jp2-codestream"
        "x-sgi"
        "x-sun-raster"
        "x-xbitmap"
        "x-xcf"
        "x-xwindowdump"
        # keep-sorted end
      ])
      ++ (mimeAppEntries "application" "gimp.desktop" [
        # keep-sorted start
        "fits"
        "x-navi-animation"
        # keep-sorted end
      ])
      # keep-sorted end
    );
  };
}
