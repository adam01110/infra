{inputs, ...}: {
  flake-file.inputs.eh = {
    url = "github:NotAShelf/eh";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.eh = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (pkgs.stdenv.hostPlatform) system;

    # The eh package installs a `,` multicall symlink that shadows
    # nix-index-database's comma command; drop it while keeping eh and the
    # other multicall binaries.
    eh = inputs.eh.packages.${system}.eh.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          rm -f $out/bin/,
          rm -f $out/share/bash-completion/completions/,.bash
          rm -f $out/share/zsh/site-functions/_,
          rm -f $out/share/fish/vendor_completions.d/,.fish
        '';
    });
  in {
    home.packages = [eh];

    programs.fish.interactiveShellInitSnippets = [
      # Alias eh's non-conflicting multicall names to explicit subcommands so
      # they still work even if the PATH symlinks are unavailable.
      ''
        alias nr='${getExe eh} run'
        alias ns='${getExe eh} shell'
        alias nb='${getExe eh} build'
        alias nd='${getExe eh} develop'
        alias ni='${getExe eh} info'
        alias nu='${getExe eh} update'
        alias dev='${getExe eh} develop'
      ''
    ];
  };
}
