{
  flake.modules.homeManager.steam = {pkgs, ...}: let
    inherit (pkgs) fetchurl fetchzip;

    # Release archive holding plugin.json, the backend and a built frontend bundle.
    fetchPlugin = {
      # keep-sorted start
      asset,
      hash,
      repo,
      tag,
      stripRoot ? true,
      # keep-sorted end
    }:
      fetchzip {
        inherit hash stripRoot;
        url = "https://github.com/${repo}/releases/download/${tag}/${asset}";
      };

    # Single-file package, which Millennium 3 loads next to unpacked plugins.
    fetchStar = {
      # keep-sorted start
      asset,
      hash,
      repo,
      tag,
      # keep-sorted end
    }:
      fetchurl {
        inherit hash;
        url = "https://github.com/${repo}/releases/download/${tag}/${asset}";
      };
  in {
    programs.steam.millennium = {
      # Star packages register their metadata name, not their id or file name.
      config.plugins.enabledPlugins = [
        # keep-sorted start
        "ProtonDB"
        "Size on Disk"
        "extendium"
        "hltb-for-millennium"
        "non-steam-playtimes"
        "steam-easygrid"
        # keep-sorted end
      ];

      plugins = {
        # keep-sorted start block=yes newline_separated=yes
        "com.unicxrn.protondb.star" = fetchStar {
          asset = "protondb-v2.0.0.star";
          hash = "sha256-AIn6rFyFy/KaH0W2a8CzOa2bgkUC2LlShJ6Qzb5vDEA=";
          repo = "unicxrn/protondb-millennium";
          tag = "v2.0.0";
        };

        "size-on-disk.star" = fetchStar {
          asset = "size-on-disk-1.3.1.star";
          hash = "sha256-VJohLQSYLCj71zBlTM5yqS8iuER2lCYDPdkfj2YtTAo=";
          repo = "k0d13/steam-size-on-disk";
          tag = "v1.3.1";
        };

        extendium = fetchPlugin {
          asset = "extendium-2.0.5.zip";
          hash = "sha256-xLgXWSU06onhi5JACcxbTh3qrgVqtkNRco1dbvcWLtk=";
          repo = "BossSloth/Extendium";
          tag = "v2.0.5";
        };

        hltb-for-millennium = fetchPlugin {
          asset = "hltb-for-millennium-2.2.0.zip";
          hash = "sha256-LH9JzLHSIOgJcasPEsFwQkninysyyzty37xDnFv0m/g=";
          repo = "jcdoll/hltb-millennium-plugin";
          tag = "v2.2.0";
        };

        non-steam-playtimes = fetchPlugin {
          asset = "non-steam-playtimes-2.0.3.zip";
          hash = "sha256-O5f63HPaIEKTDvXAdD2ZxJmFyyJUU1/k7UFk6V4Htyw=";
          repo = "k0d13/steam-non-steam-playtimes";
          stripRoot = false;
          tag = "v2.0.3";
        };

        steam-easygrid = fetchPlugin {
          asset = "steam-easygrid.zip";
          hash = "sha256-Awr50Lf6F5Ynk+5vGVyG+ezvAUdosshZUaiKtkFvx6U=";
          repo = "luthor112/steam-easygrid";
          stripRoot = false;
          tag = "dev-98b8c45f12c6c45ac61c94618ba74a4f4db3c4d2";
        };
        # keep-sorted end
      };
    };
  };
}
