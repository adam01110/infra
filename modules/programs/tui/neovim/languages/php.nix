{
  flake.aspects.neovim.homeManager = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
  in {
    programs.nvf.settings.vim = {
      languages.php = {
        enable = true;

        # keep-sorted start block=yes newline_separated=yes
        extraDiagnostics.types = [
          # keep-sorted start
          "mago_analyze"
          "mago_lint"
          # keep-sorted end
        ];

        format.type = ["mago"];

        # Nvf has no phoxite preset, so the server is defined below.
        lsp.servers = [];
        # keep-sorted end
      };

      lsp.servers.phoxite = {
        enable = true;
        cmd = [(getExe pkgs.nur.repos.adam0.phoxite)];

        filetypes = [
          # keep-sorted start
          "blade"
          "php"
          "twig"
          # keep-sorted end
        ];

        root_markers = [
          # keep-sorted start
          ".git"
          "composer.json"
          # keep-sorted end
        ];
      };
    };
  };
}
