{self, ...}: {
  flake.modules.homeManager.gh = {vars, ...}: let
    inherit (vars) gitUsername;
  in {
    imports = with self.modules; [
      # keep-sorted start block=yes
      generic.vars
      {
        key = "homeManager-git";
        imports = [homeManager.git];
      }
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
