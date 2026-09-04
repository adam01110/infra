{
  flake.modules.homeManager.neovim.programs.nvf.settings.vim.languages.python = {
    enable = true;

    # keep-sorted start
    format.type = ["ruff"];
    lsp.servers = ["ty"];
    # keep-sorted end
  };
}
