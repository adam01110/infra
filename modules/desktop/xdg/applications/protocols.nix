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
      (mimeAppEntries "x-scheme-handler" "zen-beta.desktop" [
        "http"
        "https"
      ])
      ++ (mimeAppEntries "x-scheme-handler" "beepertexts.desktop" [
        "beeper"
      ])
      ++ (mimeAppEntries "x-scheme-handler" "bitwarden.desktop" [
        "bitwarden"
      ])
      ++ (mimeAppEntries "x-scheme-handler" "obsidian.desktop" [
        "obsidian"
      ])
      ++ (mimeAppEntries "x-scheme-handler" "onlyoffice-desktopeditors.desktop" [
        "oo-office"
      ])
      ++ (mimeAppEntries "x-scheme-handler" "org.prismlauncher.PrismLauncher.desktop" [
        # keep-sorted start
        "curseforge"
        "prismlauncher"
        # keep-sorted end
      ])
      ++ (mimeAppEntries "x-scheme-handler" "org.vinegarhq.Sober.desktop" [
        # keep-sorted start
        "roblox"
        "roblox-player"
        # keep-sorted end
      ])
      ++ (mimeAppEntries "x-scheme-handler" "steam.desktop" [
        # keep-sorted start
        "steam"
        "steamlink"
        # keep-sorted end
      ])
      # keep-sorted end
    );
  };
}
