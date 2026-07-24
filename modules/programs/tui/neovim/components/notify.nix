{
  flake.modules.homeManager.neovim = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib.generators) mkLuaInline;

    inherit (config.programs.nvf.settings.vim.ui) borderType;
  in {
    programs.nvf.settings.vim.notify.nvim-notify = {
      enable = true;

      setupOpts = {
        render = "default";
        stages = "static";

        on_open = mkLuaInline ''
          function(win)
            vim.api.nvim_win_set_config(win, { border = ${builtins.toJSON borderType} })
          end
        '';
      };
    };
  };
}
