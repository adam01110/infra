{
  flake.modules.homeManager.bun = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      getExe'
      # keep-sorted end
      ;

    # keep-sorted start
    bun = getExe config.programs.bun.package;
    bunx = getExe' config.programs.bun.package "bunx";
    # keep-sorted end
  in {
    programs.bun = {
      enable = true;

      # Why the fuck would javascript need telemetry.
      settings.telementry = false;
    };

    home.shellAliases = {
      # keep-sorted start
      inherit bunx;
      npm = bun;
      npx = bunx;
      pnpm = bun;
      pnpx = bunx;
      yarn = bun;
      yarnpkg = bun;
      # keep-sorted end
    };
  };
}
