{
  flake.modules.homeManager.yazi = {
    # keep-sorted start
    config,
    osConfig,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (builtins)
      # keep-sorted start
      attrValues
      listToAttrs
      # keep-sorted end
      ;
    inherit (pkgs.lib.attrsets) nameValuePair;
    inherit (pkgs.lib.generators) mkLuaInline;
  in {
    programs.yazi = {
      package = pkgs.yazi.override {
        optionalDeps =
          attrValues {
            inherit
              (pkgs)
              # keep-sorted start
              _7zz
              chafa
              ffmpeg
              imagemagick
              jq
              poppler-utils
              resvg
              # keep-sorted end
              ;
          }
          # Reuse packages from home-manager modules to avoid duplicate package selections.
          ++ (map (program: config.programs.${program}.package) [
            # keep-sorted start
            "fd"
            "ripgrep"
            # keep-sorted end
          ]);
      };

      # Add runtime helpers for Yazi plugins.
      extraPackages =
        attrValues {
          inherit
            (pkgs)
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
            ;
        }
        # Reuse packages from home-manager modules to avoid duplicate package selections.
        ++ (map (program: config.programs.${program}.package) [
          # keep-sorted start
          "bat"
          "fd"
          "git"
          "ripgrep"
          "television"
          # keep-sorted end
        ])
        # Pull packaged tools from the system config when home-manager does not own them.
        ++ [osConfig.services.udisks2.package];

      plugins = let
        mkPlugin = source: name: nameValuePair name source.${name};

        # Keep plugins without dedicated modules together here.
        # Plugins from nixpkgs.
        nixpkgsPlugins = [
          # keep-sorted start
          "full-border"
          "git"
          "starship"
          # keep-sorted end
        ];

        # Plugins from adam0's nur.
        adam0Plugins = ["spot"];
      in
        listToAttrs (
          (map (mkPlugin pkgs.yaziPlugins) nixpkgsPlugins)
          ++ (map (mkPlugin pkgs.nur.repos.adam0.yaziPlugins) adam0Plugins)
        );

      pluginSetupOpts = {
        # keep-sorted start newline_separated=yes
        full-border.type = mkLuaInline "ui.Border.PLAIN";

        spot.metadata_section.relative_time = false;

        starship = {};
        # keep-sorted end
      };
    };
  };
}
