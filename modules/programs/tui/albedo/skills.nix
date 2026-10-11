{inputs, ...}: {
  flake.modules.homeManager.albedo = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      escapeShellArg
      getExe
      mkIf
      # keep-sorted end
      ;
    inherit (lib.hm.dag) entryAfter;

    inherit (inputs.albedo-suite.packages.${pkgs.stdenv.hostPlatform.system}) albedo-configure;

    jsonFormat = pkgs.formats.json {};

    cfg = config.programs.albedo;

    skillChoices = jsonFormat.generate "albedo-skills.json" {
      global.skills = {
        # keep-sorted start
        complexity-review = false;
        customize-albedo = true;
        design-preflight = false;
        orchestrating-agents = true;
        research = false;
        running-experiments = false;
        # keep-sorted end
      };
    };
  in {
    home.activation.configureAlbedoSkills = mkIf cfg.enable (entryAfter ["configureAlbedoSettings"] ''
      run ${getExe albedo-configure} ${escapeShellArg cfg.home} ${skillChoices} capabilities.json
    '');
  };
}
