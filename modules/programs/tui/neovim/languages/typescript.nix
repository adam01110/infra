{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim.languages.typescript = {
      enable = true;
      format.type = ["biome"];

      extensions.ts-error-translator = {
        enable = true;
        setupOpts.servers = ["ts_ls"];
      };
    };
  };
}
