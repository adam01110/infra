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
    packages.telescope-all-recent-nvim = buildVimPlugin {
      pname = "telescope-all-recent.nvim";
      version = "0-unstable-2025-03-19";

      src = fetchFromGitHub {
        owner = "prochri";
        repo = "telescope-all-recent.nvim";
        rev = "e437f60ea468268e49ffdc0c9ed7c5ba384e63cf";
        hash = "sha256-Dq0eahhshmgdrof9eG3rBNm06UCCsjMYNkBs4KE/cEQ=";
      };

      dependencies = with pkgs.vimPlugins; [
        # keep-sorted start
        plenary-nvim
        sqlite-lua
        telescope-nvim
        # keep-sorted end
      ];

      meta = with lib; {
        description = "Frecency sorting for all Telescope pickers";
        homepage = "https://github.com/prochri/telescope-all-recent.nvim";
        license = licenses.mit;
        platforms = platforms.all;
      };
    };
  };
}
