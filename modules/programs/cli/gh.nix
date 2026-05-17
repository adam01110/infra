{self, ...}: {
  flake.modules.homeManager.gh = {vars, ...}: let
    inherit (vars) gitUsername;
  in {
    imports = [
      # keep-sorted start
      self.modules.generic.vars
      self.modules.homeManager.git
      # keep-sorted end
    ];

    programs.gh = {
      enable = true;

      hosts."github.com".user = gitUsername;

      settings = {
        # keep-sorted start
        git_protocol = "ssh";
        telemetry = "disabled";
        # keep-sorted end
      };
    };

    home.sessionVariables.GH_TELEMETRY = false;
  };
}
