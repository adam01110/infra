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
    packages.nocheatsheet-nvim = buildVimPlugin {
      pname = "noCheatSheet.nvim";
      version = "0-unstable-2026-05-03";

      src = fetchFromGitHub {
        owner = "adam01110";
        repo = "noCheatSheet.nvim";
        rev = "c5365c0ebf1ca8d2ec47be99706926b8e0c2947d";
        hash = "sha256-aQJ/Dk8DoWtK8q7arD7MA1jSe/3l2n02h6CD78lLSvI=";
      };

      meta = with lib; {
        description = "Standalone NvChad-style cheatsheet for Neovim";
        homepage = "https://github.com/adam01110/noCheatSheet.nvim";
        license = licenses.gpl3Only;
        platforms = platforms.all;
      };
    };
  };
}
