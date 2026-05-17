{self, ...}: {
  flake.modules.homeManager.opencode = {pkgs, ...}: {
    imports = [
      # keep-sorted start
      pkgs.nur.repos.adam0.hmModules.opencode-plugins
      self.modules.homeManager.nur
      # keep-sorted end
    ];

    programs.opencode.plugins = {
      # keep-sorted start
      cc-safety-net.enable = true;
      changelog.enable = true;
      dynamic-context-pruning.enable = true;
      ignore.enable = true;
      lazy-mcp.enable = true;
      oc-tps.enable = true;
      unmoji.enable = true;
      # keep-sorted end

      # keep-sorted start block=yes newline_separated=yes
      notifier = {
        enable = true;
        settings.sound = false;
      };

      quota = {
        enable = true;
        sidebar.enable = true;

        settings = {
          # keep-sorted start
          enableToast = false;
          formatStyle = "allWindows";
          # keep-sorted end
        };
      };
      # keep-sorted end
    };
  };
}
