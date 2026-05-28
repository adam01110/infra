{
  flake.modules.homeManager.neovim = {
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
