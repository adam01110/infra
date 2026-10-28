{
  flake.modules.homeManager.glab = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      concatLists
      escapeShellArgs
      mapAttrsToList
      # keep-sorted end
      ;
    inherit (lib.self) mkGlamourStyle;

    jsonFormat = pkgs.formats.json {};

    colors = config.lib.stylix.colors.withHashtag;
    glamourStyle = jsonFormat.generate "glab-stylix.json" (mkGlamourStyle colors);

    # Replace the upstream brand palette in help and interactive prompts.
    brandColors = {
      # keep-sorted start
      "#1068BF" = colors.base0D;
      "#171321" = colors.base00;
      "#217645" = colors.base0B;
      "#34D058" = colors.base0B;
      "#4285F4" = colors.base0D;
      "#6B6B73" = colors.base04;
      "#7759C2" = colors.base0E;
      "#A989F5" = colors.base0E;
      "#B0B0B0" = colors.base04;
      "#C91C00" = colors.base08;
      "#F97583" = colors.base08;
      "#FAFAFA" = colors.base05;
      "#FC6D26" = colors.base09;
      "#FFFFFF" = colors.base00;
      # keep-sorted end
    };

    glab = pkgs.glab.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace internal/theme/gitlab.go ${escapeShellArgs (concatLists (mapAttrsToList (from: to: ["--replace-fail" from to]) brandColors))}
          substituteInPlace internal/theme/gitlab.go --replace-fail 'return scheme' 'scheme.Base = colors.Text
          scheme.Codeblock = lipgloss.Color("${colors.base01}")
          return scheme'
          substituteInPlace internal/iostreams/color.go --replace-fail 'nil, "black+h"' 'glc.Subtle, "black+h"'
        '';
      postInstall =
        (old.postInstall or "")
        + ''
          wrapProgram $out/bin/glab --set-default GLAB_GLAMOUR_STYLE ${glamourStyle}
        '';
    });
  in {
    home.packages = [glab];
  };
}
