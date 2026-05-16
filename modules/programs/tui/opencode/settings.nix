{
  flake.modules.homeManager.opencode = {config, ...}: let
    home = config.home.homeDirectory;
  in {
    programs.opencode = {
      settings = {
        # keep-sorted start block=yes newline_separated=yes
        autoupdate = false;

        permission.external_directory = {
          # keep-sorted start
          "${home}/Infra/**" = "allow";
          "/nix/store/**" = "allow";
          # keep-sorted end
        };

        watcher.ignore = [
          # keep-sorted start
          ".direnv/**"
          ".git/**"
          ".rumdl_cache/**"
          "dist/**"
          "node_modules/**"
          "target/**"
          # keep-sorted end
        ];
        # keep-sorted end

        # keep-sorted start
        agent.explore.reasoningEffort = "medium";
        agent.general.reasoningEffort = "medium";
        # keep-sorted end
      };

      tui.scroll_acceleration.enabled = true;
    };
  };
}
