{
  flake.modules.homeManager.neovim = {pkgs, ...}: {
    programs.nvf.settings.vim = {
      languages.rust = {
        enable = true;
        format.enable = true;

        extensions.crates-nvim = {
          enable = true;

          setupOpts.popup = {
            autofocus = true;
            show_version_date = true;
          };
        };
      };

      lsp.servers."rust-analyzer".settings."rust-analyzer".rustfmt.overrideCommand = [
        "${pkgs.rustfmt}/bin/rustfmt"
      ];
    };
  };
}
