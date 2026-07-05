{
  flake.modules.homeManager.delta = {
    # keep-sorted start
    lib,
    osConfig,
    # keep-sorted end
    ...
  }: let
    inherit (lib.self) blendHex;

    colors = osConfig.lib.stylix.colors.withHashtag;
  in {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;

      options = with colors; {
        true-color = "always";
        line-numbers = true;
        side-by-side = true;
        syntax-theme = "base16-stylix";

        # Let the desktop MIME handler open linked files.
        hyperlinks = true;
        hyperlinks-file-link-format = "file://{path}#{line}";

        # keep-sorted start
        blame-palette = "${base00} ${base01} ${base02}";
        file-style = "${base0D} bold";
        hunk-header-decoration-style = "${base0D} ul";
        hunk-header-file-style = "${base0D} ul bold";
        hunk-header-line-number-style = "${base0A} box bold";
        line-numbers-left-style = base0D;
        line-numbers-minus-style = base08;
        line-numbers-plus-style = base0B;
        line-numbers-right-style = base0D;
        line-numbers-zero-style = base03;
        merge-conflict-ours-diff-header-decoration-style = "${base0D} box";
        merge-conflict-ours-diff-header-style = "${base0A} bold";
        merge-conflict-theirs-diff-header-decoration-style = "${base0D} box";
        merge-conflict-theirs-diff-header-style = "${base0A} bold";
        minus-emph-style = "${base00} ${blendHex 34 base00 base08}";
        minus-style = "syntax ${blendHex 22 base00 base08}";
        plus-emph-style = "${base00} ${blendHex 34 base00 base0B}";
        plus-style = "syntax ${blendHex 22 base00 base0B}";
        whitespace-error-style = "${base00} bold";
        # keep-sorted end
      };
    };
  };
}
