{
  perSystem = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (pkgs) fetchFromGitHub;
    inherit (pkgs.vimUtils) buildVimPlugin;
  in {
    packages.jj-conflict-nvim = buildVimPlugin {
      pname = "jj-conflict.nvim";
      version = "0-unstable-2026-07-05";

      src = fetchFromGitHub {
        owner = "larpios";
        repo = "jj-conflict.nvim";
        rev = "b5c7b64a35a2538a27d36d45a91154306f5fb548";
        hash = "sha256-tnOXxYlU+GetU/ns9IkZ2K+gz7PAtBhZg6dR5owZidU=";
      };

      meta = with lib; {
        description = "Visualize and resolve Jujutsu merge conflicts in Neovim";
        homepage = "https://github.com/larpios/jj-conflict.nvim";
        license = licenses.mit;
        platforms = platforms.all;
      };
    };
  };
}
