{
  flake.modules.homeManager.onlyoffice = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      escapeShellArg
      concatMapStringsSep
      # keep-sorted end
      ;
    inherit (lib.hm.dag) entryAfter;
    inherit (pkgs) writeShellApplication;
    inherit (vars) fullName;

    fontsDir = "${config.xdg.dataHome}/fonts/onlyoffice";

    # OnlyOffice lists user fonts that are regular files, so the fonts are
    # hardlinked into the user font directory instead of being symlinked.
    installFonts = writeShellApplication {
      name = "onlyoffice-install-fonts";

      runtimeInputs = with pkgs; [
        coreutils
        findutils
      ];

      text = ''
        dest="$1"
        shift
        mkdir -p "$dest"
        find "$dest" -mindepth 1 -type f -delete
        for dir in "$@"; do
          find "$dir" -type f \( -name '*.otf' -o -name '*.ttc' -o -name '*.ttf' \) | while IFS= read -r font; do
            ln -f "$font" "$dest/" 2>/dev/null || cp -f "$font" "$dest/"
          done
        done
      '';
    };

    officeFonts = with pkgs; [
      # keep-sorted start
      caladea
      carlito
      corefonts
      dejavu_fonts
      eb-garamond
      freefont_ttf
      gelasio
      gyre-fonts
      liberation-sans-narrow
      liberation_ttf
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      symbola
      unifont
      vista-fonts
      # keep-sorted end
    ];
  in {
    # OnlyOffice discovers user fonts in the XDG font directory, not in the
    # font list of its own FHS environment.
    home.activation.onlyofficeFonts = entryAfter ["writeBoundary"] ''
      run ${installFonts}/bin/onlyoffice-install-fonts ${escapeShellArg fontsDir} ${concatMapStringsSep " " (package: escapeShellArg "${package}/share/fonts") officeFonts}
    '';

    programs.onlyoffice = {
      # keep-sorted start block=yes newline_separated=yes
      enable = true;

      settings = {
        # keep-sorted start
        # OnlyOffice keeps the gtk dialog unless this flag is set.
        "--xdg-desktop-portal" = true;
        UITheme = "theme-dark";
        uiscaling = 100;
        usegpu = true;
        username = fullName;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
