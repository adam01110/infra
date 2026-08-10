{
  flake-file.inputs.codexbar = {
    url = "github:0xferrous/CodexBar-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.codexbar = {
    # keep-sorted start
    config,
    inputs,
    pkgs,
    # keep-sorted end
    ...
  }: let
    codexbar = inputs.codexbar.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      installPhase =
        old.installPhase
        + ''
          cp -r CodexBar_CodexBarCore.bundle "$out/bin/"
        '';
    });
  in {
    home.sessionVariables.CODEX_HOME = "${config.xdg.configHome}/codex";
    home.packages = [codexbar];
  };
}
