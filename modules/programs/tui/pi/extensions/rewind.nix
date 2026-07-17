{
  flake.modules.homeManager.pi = {pkgs, ...}: let
    piRewind = pkgs.stdenvNoCC.mkDerivation {
      pname = "pi-rewind";
      version = "0.5.0";

      src = pkgs.fetchFromGitHub {
        owner = "arpagon";
        repo = "pi-rewind";
        rev = "v0.5.0";
        hash = "sha256-fkMabHbwD5AuvOi4/f5GsbzOqrF5EbEwdCYBUWk06RQ=";
      };

      postPatch = ''
        substituteInPlace src/core.ts \
          --replace-fail \
            $'export const IGNORED_DIR_NAMES = new Set([\n  "node_modules",' \
            $'export const IGNORED_DIR_NAMES = new Set([\n  ".direnv",\n  ".git",\n  ".rumdl_cache",\n  "target",\n  "vendor",\n  "node_modules",'
      '';

      installPhase = ''
        runHook preInstall
        cp -r . "$out"
        runHook postInstall
      '';
    };
  in {
    programs.pi.coding-agent.extensions = ["${piRewind}/src/index.ts"];
  };
}
