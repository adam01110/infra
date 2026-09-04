{
  flake.modules.homeManager.yazi = {
    # keep-sorted start
    config,
    lib,
    osConfig,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib.generators) mkLuaInline;
  in {
    programs.yazi = {
      package = pkgs.yazi.override {
        optionalDeps =
          (with pkgs; [
            # keep-sorted start
            _7zz
            chafa
            ffmpeg
            imagemagick
            jq
            poppler-utils
            resvg
            # keep-sorted end
          ])
          # Reuse Home Manager package selections.
          ++ (map (program: config.programs.${program}.package) [
            # keep-sorted start
            "fd"
            "ripgrep"
            # keep-sorted end
          ]);
      };

      extraPackages =
        (with pkgs; [
          # keep-sorted start
          _7zz
          chafa
          # spot
          coreutils
          ffmpeg
          # preview-epub
          gnome-epub-thumbnailer
          imagemagick
          # spot-image
          inkscape
          jq
          # mediainfo & spot-audio
          mediainfo
          poppler-utils
          resvg
          # recycle-bin
          trash-cli
          # preview-cbz
          unrar
          # spot-cbz & preview-cbz
          unzip
          # mount
          util-linux
          # ucp
          wl-clipboard
          # keep-sorted end
          # faster-piper
          glow
          sqlite
        ])
        # Reuse Home Manager package selections.
        ++ (map (program: config.programs.${program}.package) [
          # keep-sorted start
          "bat"
          "fd"
          "git"
          "ripgrep"
          "television"
          # keep-sorted end
        ])
        # Use the system-owned udisks package.
        ++ [osConfig.services.udisks2.package];

      # Group plugins without dedicated modules.
      plugins = {
        # keep-sorted start block=yes newline_separated=yes
        full-border = {
          package = pkgs.yaziPlugins.full-border;
          setup = true;
          settings.type = mkLuaInline "ui.Border.PLAIN";
        };

        git = pkgs.yaziPlugins.git;

        spot = {
          package = pkgs.nur.repos.adam0.yaziPlugins.spot;
          setup = true;
          settings.metadata_section.relative_time = false;
        };

        starship = {
          package = pkgs.yaziPlugins.starship;
          setup = true;
        };
        # keep-sorted end
      };
    };
  };
}
