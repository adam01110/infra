{
  flake.modules.homeManager.neovim = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib.generators) mkLuaInline;
  in {
    programs.nvf.settings.vim.utility.yazi-nvim = {
      enable = true;

      setupOpts = {
        integrations.grep_in_directory = mkLuaInline ''
          function(directory)
            vim.defer_fn(function()
              _G.telescope_pick("live_grep", {
                cwd = directory,
                prompt_title = "Grep in " .. directory,
                search = "",
              })
            end, 50)
          end
        '';

        integrations.grep_in_selected_files = mkLuaInline ''
          function(_, relative_paths)
            vim.defer_fn(function()
              _G.telescope_pick("live_grep", {
                prompt_title = string.format("Grep in %d paths", #relative_paths),
                search = "",
                search_dirs = relative_paths,
              })
            end, 50)
          end
        '';

        # keep-sorted start
        change_neovim_cwd_on_close = true;
        open_for_directories = true;
        open_multiple_tabs = true;
        yazi_floating_window_border = config.programs.nvf.settings.vim.ui.borderType;
        # keep-sorted end
      };
    };
  };
}
