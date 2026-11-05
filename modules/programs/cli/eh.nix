{inputs, ...}: {
  flake-file.inputs.eh = {
    url = "github:NotAShelf/eh";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.eh = {
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
      getExe
      makeBinPath
      optionalString
      # keep-sorted end
      ;
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit
      (pkgs)
      # keep-sorted start
      symlinkJoin
      writeShellScriptBin
      # keep-sorted end
      ;

    cfg = config.programs.nix-your-shell;

    # Bridge subprocesses that cannot see fish's nix function.
    nixForEh = writeShellScriptBin "nix" ''
      export PATH="${makeBinPath [config.nix.package]}:$PATH"
      exec ${getExe cfg.package} ${optionalString cfg.nix-output-monitor.enable "--nom"} ${getExe config.programs.fish.package} nix -- "$@"
    '';

    eh = symlinkJoin {
      name = "eh-with-fish";
      paths = [inputs.eh.packages.${system}.eh];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        # Leave comma to nix-index-database.
        rm -f $out/bin/,
        rm -f $out/share/bash-completion/completions/,.bash
        rm -f $out/share/zsh/site-functions/_,
        rm -f $out/share/fish/vendor_completions.d/,.fish
        for program in "$out"/bin/*; do
          wrapProgram "$program" --argv0 "$(basename "$program")" --prefix PATH : ${nixForEh}/bin
        done
      '';
      meta.mainProgram = "eh";
    };
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
