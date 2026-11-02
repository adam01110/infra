{
  flake.modules.homeManager.neovim.programs.nvf.settings.vim.languages.php = {
    enable = true;

    # keep-sorted start block=yes newline_separated=yes
    extraDiagnostics.types = [
      # keep-sorted start
      "mago_analyze"
      "mago_lint"
      # keep-sorted end
    ];

    format.type = ["mago"];

    lsp.servers = ["phpantom"];
    # keep-sorted end
  };
}
