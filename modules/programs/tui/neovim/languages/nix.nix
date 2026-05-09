{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim.languages.nix = {
      enable = true;

      # keep-sorted start
      format.type = ["alejandra"];
      lsp.servers = ["nixd"];
      # keep-sorted end
    };
  };
}
