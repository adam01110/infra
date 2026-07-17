{
  flake.modules.homeManager.pi = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      genAttrs
      getExe
      getExe'
      # keep-sorted end
      ;
    jsonFormat = pkgs.formats.json {};
    mkServer = {
      args ? [],
      bin,
      extensions,
      id,
      languageId,
      languageIdByExtension ? genAttrs extensions (_: languageId),
      rootMarkers ? [".git"],
    }: {
      inherit
        args
        bin
        id
        languageIdByExtension
        rootMarkers
        ;
      enabled = true;
      include = map (extension: "**/*${extension}") extensions;
      cwd = "{root}";
      startupTimeoutMs = 45000;
      diagnosticsWaitMs = 2000;
      initializationOptions = {};
      settings = {};
    };
  in {
    programs.pi.coding-agent.extensions = ["npm:pi-lsp@0.1.7"];

    home.file.".pi/agent/lsp.json".source = jsonFormat.generate "pi-lsp.json" {
      version = 1;
      servers = [
        # keep-sorted start block=yes newline_separated=yes
        (mkServer {
          id = "bash";
          bin = getExe pkgs.bash-language-server;
          args = ["start"];
          extensions = [
            # keep-sorted start
            ".bash"
            ".sh"
            # keep-sorted end
          ];
          languageId = "shellscript";
        })

        (mkServer {
          id = "csharp";
          bin = getExe pkgs.csharp-ls;
          extensions = [
            # keep-sorted start
            ".cs"
            ".csx"
            # keep-sorted end
          ];
          languageId = "csharp";
        })

        (mkServer {
          id = "cssls";
          bin = getExe' pkgs.vscode-langservers-extracted "vscode-css-language-server";
          args = ["--stdio"];
          extensions = [".css"];
          languageId = "css";
          rootMarkers = [
            # keep-sorted start
            ".git"
            "package.json"
            # keep-sorted end
          ];
        })

        (mkServer {
          id = "jdtls";
          bin = getExe pkgs.jdt-language-server;
          extensions = [".java"];
          languageId = "java";
          rootMarkers = [
            # keep-sorted start
            ".git"
            "build.gradle"
            "build.gradle.kts"
            "pom.xml"
            "settings.gradle"
            "settings.gradle.kts"
            # keep-sorted end
          ];
        })

        (mkServer {
          id = "json";
          bin = getExe pkgs.vscode-json-languageserver;
          args = ["--stdio"];
          extensions = [
            # keep-sorted start
            ".json"
            ".jsonc"
            # keep-sorted end
          ];
          languageId = "json";
          languageIdByExtension = {
            ".json" = "json";
            ".jsonc" = "jsonc";
          };
          rootMarkers = [
            # keep-sorted start
            ".git"
            "package.json"
            # keep-sorted end
          ];
        })

        (mkServer {
          id = "kotlin-ls";
          bin = getExe pkgs.kotlin-language-server;
          extensions = [
            # keep-sorted start
            ".kt"
            ".kts"
            # keep-sorted end
          ];
          languageId = "kotlin";
          rootMarkers = [
            # keep-sorted start
            ".git"
            "build.gradle"
            "build.gradle.kts"
            "settings.gradle"
            "settings.gradle.kts"
            # keep-sorted end
          ];
        })

        (mkServer {
          id = "lemminx";
          bin = getExe pkgs.lemminx;
          extensions = [".xml"];
          languageId = "xml";
        })

        (mkServer {
          id = "lua";
          bin = getExe pkgs.lua-language-server;
          extensions = [".lua"];
          languageId = "lua";
          rootMarkers = [
            # keep-sorted start
            ".git"
            ".luarc.json"
            ".luarc.jsonc"
            # keep-sorted end
          ];
        })

        (mkServer {
          id = "nixd";
          bin = getExe pkgs.nixd;
          extensions = [".nix"];
          languageId = "nix";
          rootMarkers = [
            # keep-sorted start
            ".git"
            "flake.nix"
            # keep-sorted end
          ];
        })

        (mkServer {
          id = "oxlint";
          bin = getExe pkgs.oxlint;
          args = ["--lsp"];
          extensions = [
            # keep-sorted start
            ".js"
            ".jsx"
            ".ts"
            ".tsx"
            # keep-sorted end
          ];
          languageId = "javascript";
          languageIdByExtension = {
            ".js" = "javascript";
            ".jsx" = "javascriptreact";
            ".ts" = "typescript";
            ".tsx" = "typescriptreact";
          };
          rootMarkers = [
            # keep-sorted start
            ".git"
            "oxlint.json"
            "package.json"
            # keep-sorted end
          ];
        })

        (mkServer {
          id = "rumdl";
          bin = getExe pkgs.rumdl;
          args = ["server"];
          extensions = [
            # keep-sorted start
            ".markdown"
            ".md"
            # keep-sorted end
          ];
          languageId = "markdown";
          rootMarkers = [
            # keep-sorted start
            ".git"
            ".rumdl.toml"
            # keep-sorted end
          ];
        })

        (mkServer {
          id = "rust";
          bin = getExe pkgs.rust-analyzer;
          extensions = [".rs"];
          languageId = "rust";
          rootMarkers = [
            # keep-sorted start
            ".git"
            "Cargo.toml"
            # keep-sorted end
          ];
        })

        (mkServer {
          id = "superhtml";
          bin = getExe pkgs.superhtml;
          args = ["lsp"];
          extensions = [".html"];
          languageId = "html";
        })

        (mkServer {
          id = "tombi";
          bin = getExe pkgs.tombi;
          args = ["lsp"];
          extensions = [".toml"];
          languageId = "toml";
          rootMarkers = [
            # keep-sorted start
            ".git"
            "tombi.toml"
            # keep-sorted end
          ];
        })

        (mkServer {
          id = "ty";
          bin = getExe pkgs.ty;
          args = ["server"];
          extensions = [
            # keep-sorted start
            ".py"
            ".pyi"
            # keep-sorted end
          ];
          languageId = "python";
          rootMarkers = [
            # keep-sorted start
            ".git"
            "pyproject.toml"
            # keep-sorted end
          ];
        })

        (mkServer {
          id = "typescript";
          bin = getExe pkgs.typescript-language-server;
          args = ["--stdio"];
          extensions = [
            # keep-sorted start
            ".js"
            ".jsx"
            ".ts"
            ".tsx"
            # keep-sorted end
          ];
          languageId = "javascript";
          languageIdByExtension = {
            ".js" = "javascript";
            ".jsx" = "javascriptreact";
            ".ts" = "typescript";
            ".tsx" = "typescriptreact";
          };
          rootMarkers = [
            # keep-sorted start
            ".git"
            "package.json"
            "tsconfig.json"
            # keep-sorted end
          ];
        })

        (mkServer {
          id = "yaml-ls";
          bin = getExe pkgs.yaml-language-server;
          args = ["--stdio"];
          extensions = [
            # keep-sorted start
            ".yaml"
            ".yml"
            # keep-sorted end
          ];
          languageId = "yaml";
        })
        # keep-sorted end
      ];
    };
  };
}
