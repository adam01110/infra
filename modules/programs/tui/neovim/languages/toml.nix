{
  flake.aspects.neovim.homeManager.programs.nvf.settings.vim.languages.toml = {
    enable = true;

    # keep-sorted start
    format.type = ["tombi"];
    lsp.servers = ["tombi"];
    # keep-sorted end
  };
}
