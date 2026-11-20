{
  flake.aspects.albedo.homeManager = {
    # keep-sorted start
    albedoSuitePackages,
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

    inherit (albedoSuitePackages) albedo-configure;

    jsonFormat = pkgs.formats.json {};

    cfg = config.programs.albedo;

    skillChoices = jsonFormat.generate "albedo-skills" {
      global.skills = {
        # keep-sorted start
        complexity-review = false;
        customize-albedo = true;
        design-preflight = false;
        imagegen = false;
        orchestrating-agents = true;
        research = false;
        running-experiments = false;
        # keep-sorted end
      };
    };
  in {
    # The CLI behind the modern-web-guidance skill, serving the rewritten guides.
    home.packages = [
      (pkgs.nur.repos.adam0.modern-web-guidance.override {
        guides = ./skills/modern-web-guidance/guides;
      })
    ];

    home.activation.configureAlbedoSkills = mkIf cfg.enable (entryAfter ["configureAlbedoSettings"] ''
      run ${getExe albedo-configure} ${escapeShellArg cfg.home} ${skillChoices} capabilities.json
    '');
  };
}
