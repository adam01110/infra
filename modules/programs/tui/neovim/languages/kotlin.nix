{
  flake.aspects.neovim.homeManager = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
  in {
    programs.nvf.settings.vim = {
      # keep-sorted start block=yes newline_separated=yes
      # Nvf has no Kotlin formatter option, so ktlint is wired into conform.
      formatter.conform-nvim = {
        enable = true;

        setupOpts = {
          # keep-sorted start
          formatters.ktlint.command = getExe pkgs.ktlint;
          formatters_by_ft.kotlin = ["ktlint"];
          # keep-sorted end
        };
      };

      languages.kotlin.enable = true;
      # keep-sorted end
    };
  };
}
