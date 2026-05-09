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
      (mimeAppEntries "video" "org.gnome.Showtime.desktop" [
        # keep-sorted start
        "3gpp"
        "3gpp2"
        "dv"
        "mp2t"
        "mp4"
        "mpeg"
        "ogg"
        "quicktime"
        "vnd.avi"
        "vnd.mpegurl"
        "vnd.rn-realvideo"
        "vnd.vivo"
        "webm"
        "x-anim"
        "x-flic"
        "x-flv"
        "x-matroska"
        "x-nsv"
        "x-ogm+ogg"
        "x-theora+ogg"
        # keep-sorted end
      ])
      ++ (mimeAppEntries "application" "org.gnome.Showtime.desktop" [
        "vnd.ms-asf"
      ])
      # keep-sorted end
    );
  };
}
