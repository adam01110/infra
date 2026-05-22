{self, ...}: {
  flake.modules.homeManager.ripgrep-all = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) makeBinPath;
    inherit (pkgs) symlinkJoin;
  in {
    imports = [self.modules.homeManager.nur];

    programs.ripgrep-all = {
      # Wrap rga so adapters can find their runtime tools.
      package = symlinkJoin {
        name = "ripgrep-all-wrapped";
        paths = [pkgs.ripgrep-all];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/rga \
            --prefix PATH : ${
            makeBinPath (with pkgs; [
              # keep-sorted start
              csvkit
              fastgron
              nur.repos.adam0.qq-jfry
              # keep-sorted end
            ])
          }
        '';
      };
    };
  };
}
