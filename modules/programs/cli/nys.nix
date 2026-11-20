{
  flake.aspects.nys.homeManager = {pkgs, ...}: let
    inherit
      (pkgs)
      # keep-sorted start
      symlinkJoin
      writeShellApplication
      # keep-sorted end
      ;
    inherit (pkgs) nix-output-monitor rom;

    # Present rom under nom's name, since nix-your-shell runs `nom <subcommand>
    # <nix args>` and rom takes the nix args after `--`.
    romAsNom = writeShellApplication {
      name = "nom";
      runtimeInputs = [rom];
      text = ''
        subcommand=$1
        shift
        exec rom "$subcommand" -- "$@"
      '';
    };
  in {
    programs.nix-your-shell = {
      enable = true;

      # Show build progress with rom; legacy nix-shell keeps nom-shell.
      nix-output-monitor = {
        enable = true;
        package = symlinkJoin {
          name = "rom-as-nom";
          paths = [romAsNom];
          postBuild = ''
            ln -s ${nix-output-monitor}/bin/nom-shell $out/bin/nom-shell
          '';
        };
      };
    };
  };
}
