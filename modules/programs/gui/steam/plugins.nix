{
  flake.modules.homeManager.steam = {pkgs, ...}: let
    inherit (pkgs) fetchzip;

    fetchPlugin = {
      hash,
      id,
      name,
    }:
      fetchzip {
        inherit hash;
        url = "https://steambrew.app/api/v1/plugins/download/?id=${id}&n=${name}.zip";
      };
  in {
    programs.steam.millennium = {
      config.plugins.enabledPlugins = [
        # keep-sorted start
        "extendium"
        "hltb-for-millennium"
        "non-steam-playtimes"
        "protondb"
        "size-on-disk"
        "steam-easygrid"
        # keep-sorted end
      ];

      plugins = {
        # keep-sorted start block=yes newline_separated=yes
        extendium = fetchPlugin {
          hash = "sha256-t/6hMRh/HWxmMqYMwbMqT1NKY6rw+F1VaJHfalqJSAk=";
          id = "788ed8554492ebd2ebe057b8eff79fad8a6c75d5";
          name = "extendium";
        };

        hltb-for-millennium = fetchPlugin {
          hash = "sha256-Mc29zUjMfrKEqQvDUwanWZrwiDkYmKio7YGdVIWXcWQ=";
          id = "f685622bace6c63a70a24265f72fabd32aa497b5";
          name = "hltb-for-millennium";
        };

        non-steam-playtimes = fetchPlugin {
          hash = "sha256-qRK39jhTwqj1ahR35s0pUiKO01rbrokVCUKLz4gq9LA=";
          id = "02bed50d10a8b1e58fb8bba608fe6a120a3a0dca";
          name = "non-steam-playtimes";
        };

        protondb = fetchPlugin {
          hash = "sha256-eSwHAHFu4hTupTTI8vR4pFgntZNGnz0nT5ETRUG+vfI=";
          id = "7913678dca9592b28d2f619aeefd47b06ebf36a2";
          name = "protondb";
        };

        size-on-disk = fetchPlugin {
          hash = "sha256-GebzTS6GO/3bN03XIB6N0/Pb0X8aruU5KFsodU26II0=";
          id = "e73371b61eef68019413475b7642ecc37e53bbbd";
          name = "size-on-disk";
        };

        steam-easygrid = fetchPlugin {
          hash = "sha256-hpejvAqLX+YsZIFcVByzlH8cgSe7yyxNlCqvBeK50Fg=";
          id = "2519c8a9fc979627a214a78ad642ae5d5723216f";
          name = "steam-easygrid";
        };
        # keep-sorted end
      };
    };
  };
}
