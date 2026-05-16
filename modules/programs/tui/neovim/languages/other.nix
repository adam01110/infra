{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim.languages = {
      # keep-sorted start
      bash.enable = true;
      csharp.enable = true;
      fish.enable = true;
      html.enable = true;
      java.enable = true;
      json.enable = true;
      kotlin.enable = true;
      xml.enable = true;
      yaml.enable = true;
      # keep-sorted end
    };
  };
}
