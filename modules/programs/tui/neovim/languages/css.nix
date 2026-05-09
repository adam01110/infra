{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim = {
      languages.css = {
        enable = true;
        format.type = ["biome"];
      };

      lsp.presets.tailwindcss-language-server.enable = true;
    };
  };
}
