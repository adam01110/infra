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
      (mimeAppEntries "image" "org.gnome.Loupe.desktop" [
        # keep-sorted start
        "avif"
        "bmp"
        "gif"
        "heif"
        "jpeg"
        "jxl"
        "png"
        "qoi"
        "svg+xml"
        "svg+xml-compressed"
        "tiff"
        "vnd.microsoft.icon"
        "webp"
        "x-adobe-dng"
        "x-canon-cr2"
        "x-dds"
        "x-exr"
        "x-kodak-dcr"
        "x-kodak-k25"
        "x-kodak-kdc"
        "x-nikon-nef"
        "x-pentax-pef"
        "x-portable-anymap"
        "x-portable-bitmap"
        "x-portable-graymap"
        "x-portable-pixmap"
        "x-sony-arw"
        "x-sony-sr2"
        "x-sony-srf"
        "x-tga"
        # keep-sorted end
      ])
      ++ (mimeAppEntries "video" "org.gnome.Loupe.desktop" [
        "x-mjpeg"
      ])
      # keep-sorted end
    );
  };
}
