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
    xdg.mimeApps.defaultApplications = mimeAppDefaults (mimeAppEntries "audio" "org.gnome.Decibels.desktop" [
      # keep-sorted start
      "aac"
      "flac"
      "mp2"
      "mp4"
      "mpeg"
      "vnd.wave"
      "x-aiff"
      "x-ape"
      "x-m4b"
      "x-opus+ogg"
      "x-speex"
      "x-vorbis+ogg"
      "x-wavpack"
      # keep-sorted end
    ]);
  };
}
