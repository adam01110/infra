{
  flake.modules.homeManager.opencode = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      getExe'
      # keep-sorted end
      ;
  in {
    programs.opencode.settings.lsp = {
      # keep-sorted start block=yes newline_separated=yes
      bash = {
        command = [(getExe pkgs.bash-language-server) "start"];
        extensions = [
          # keep-sorted start
          ".bash"
          ".sh"
          # keep-sorted end
        ];
      };

      cssls = {
        command = [(getExe' pkgs.vscode-langservers-extracted "vscode-css-language-server")];
        extensions = ["css"];
      };

      csharp = {
        command = [(getExe pkgs.csharp-ls)];
        extensions = [
          # keep-sorted start
          ".cs"
          ".csx"
          # keep-sorted end
        ];
      };

      json = {
        command = [(getExe pkgs.vscode-json-languageserver) "--stdio"];
        extensions = [
          # keep-sorted start
          ".json"
          ".jsonc"
          # keep-sorted end
        ];
      };

      jdtls = {
        command = [(getExe pkgs.jdt-language-server)];
        extensions = [".java"];
      };

      lemminx = {
        command = [(getExe pkgs.lemminx)];
        extensions = [".xml"];
      };

      kotlin-ls = {
        command = [(getExe pkgs.kotlin-language-server)];
        extensions = [".kt" ".kts"];
      };

      lua = {
        command = [(getExe pkgs.lua-language-server)];
        extensions = [".lua"];
      };

      nixd = {
        command = [(getExe pkgs.nixd)];
        extensions = [".nix"];
      };

      oxlint = {
        command = [(getExe pkgs.oxlint)];
        extensions = [
          # keep-sorted start
          ".js"
          ".jsx"
          ".ts"
          ".tsx"
          # keep-sorted end
        ];
      };

      rumdl = {
        command = [(getExe pkgs.rumdl) "server"];
        extensions = [
          # keep-sorted start
          ".markdown"
          ".md"
          # keep-sorted end
        ];
      };

      rust = {
        command = [(getExe pkgs.rust-analyzer)];
        extensions = [".rs"];
      };

      superhtml = {
        command = [(getExe pkgs.superhtml) "lsp"];
        extensions = [".html"];
      };

      tombi = {
        command = [(getExe pkgs.tombi) "lsp"];
        extensions = [".toml"];
      };

      ty = {
        command = [(getExe pkgs.ty)];
        extensions = [
          # keep-sorted start
          ".py"
          ".pyi"
          # keep-sorted end
        ];
      };

      typescript = {
        command = [(getExe pkgs.typescript-language-server) "--stdio"];
        extensions = [
          # keep-sorted start
          ".js"
          ".jsx"
          ".ts"
          ".tsx"
          # keep-sorted end
        ];
      };

      yaml-ls = {
        command = [(getExe pkgs.yaml-language-server) "--stdio"];
        extensions = [
          # keep-sorted start
          ".yaml"
          ".yml"
          # keep-sorted end
        ];
      };
      # keep-sorted end
    };
  };
}
