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
    packages.dyninput-nvim = buildVimPlugin {
      pname = "dyninput.nvim";
      version = "0-unstable-2023-08-10";

      src = fetchFromGitHub {
        owner = "nvimdev";
        repo = "dyninput.nvim";
        rev = "2d5bef4c23d8da303556ac507416a1f9e6ea3a77";
        hash = "sha256-0jZ/hDGw58fp9G2HTcLETRh+vfQHwJBprIUxUc0gGrI=";
      };

      dependencies = [pkgs.vimPlugins.nvim-treesitter];

      meta = with lib; {
        description = "Context-aware character input for Neovim";
        homepage = "https://github.com/nvimdev/dyninput.nvim";
        license = licenses.mit;
        platforms = platforms.all;
      };
    };
  };
}
