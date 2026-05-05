{
  flake.modules.homeManager.gh = {vars, ...}: let
    inherit (vars) gitUsername;
  in {
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
