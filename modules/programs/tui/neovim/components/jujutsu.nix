{
  flake.modules.homeManager.neovim = {pkgs, ...}: {
    programs.nvf.settings.vim.lazy.plugins = {
      "jj-conflict.nvim" = {
        package = pkgs.jj-conflict-nvim;
        setupModule = "jj-conflict";

        cmd = [
          # keep-sorted start
          "JjConflictChooseBoth"
          "JjConflictChooseNone"
          "JjConflictChooseOurs"
          "JjConflictChooseTheirs"
          "JjConflictDiff"
          "JjConflictList"
          "JjConflictLog"
          "JjConflictNextConflict"
          "JjConflictPrevConflict"
          "JjConflictResolve"
          "JjConflictSquash"
          "JjConflictStatus"
          # keep-sorted end
        ];
        event = ["BufReadPre" "BufNewFile"];
      };

      "jj.nvim" = {
        package = pkgs.vimPlugins.jj-nvim;
        setupModule = "jj";

        cmd = [
          # keep-sorted start
          "J"
          "Jdiff"
          "Jhdiff"
          "Jvdiff"
          # keep-sorted end
        ];
      };
    };
  };
}
