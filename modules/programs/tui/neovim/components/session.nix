{
  flake.modules.homeManager.neovim = {lib, ...}: let
    inherit (lib.generators) mkLuaInline;
  in {
    programs.nvf.settings.vim.session.nvim-session-manager = {
      enable = true;
      usePicker = false;

      setupOpts = {
        autoload_mode = "Disabled";
        sessions_dir = mkLuaInline "require('plenary.path'):new(vim.fn.stdpath('state'), 'sessions')";
      };
    };
  };
}
