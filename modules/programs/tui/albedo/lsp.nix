{
  flake.aspects.albedo.homeManager = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      attrNames
      genAttrs
      getExe
      getExe'
      # keep-sorted end
      ;

    mkServer = {
      # keep-sorted start
      args ? [],
      bin,
      extensions,
      id,
      include ? map (extension: "**/*${extension}") extensions,
      languageId ? null,
      languageIdByExtension ? genAttrs extensions (_: languageId),
      rootMarkers ? [".git"],
      settings ? {},
      # keep-sorted end
    }: {
      inherit
        # keep-sorted start
        args
        bin
        id
        include
        languageIdByExtension
        rootMarkers
        settings
        # keep-sorted end
        ;

      # keep-sorted start
      cwd = "{root}";
      diagnosticsWaitMs = 2000;
      enabled = true;
      initializationOptions = {};
      startupTimeoutMs = 45000;
      # keep-sorted end
    };

    # Mirrors the Neovim tailwindcss-language-server filetypes.
    tailwindLanguages = {
      # keep-sorted start
      ".astro" = "astro";
      ".cjs" = "javascript";
      ".clj" = "clojure";
      ".cljc" = "clojure";
      ".cljs" = "clojure";
      ".cshtml" = "razor";
      ".css" = "css";
      ".cts" = "typescript";
      ".edge" = "edge";
      ".eex" = "eelixir";
      ".ejs" = "ejs";
      ".erb" = "eruby";
      ".ex" = "elixir";
      ".exs" = "elixir";
      ".gohtml" = "gohtml";
      ".gotmpl" = "gohtmltmpl";
      ".haml" = "haml";
      ".handlebars" = "handlebars";
      ".hbs" = "handlebars";
      ".heex" = "heex";
      ".html" = "html";
      ".jade" = "jade";
      ".js" = "javascript";
      ".jsx" = "javascriptreact";
      ".leaf" = "leaf";
      ".leex" = "eelixir";
      ".less" = "less";
      ".liquid" = "liquid";
      ".markdown" = "markdown";
      ".md" = "markdown";
      ".mjs" = "javascript";
      ".mts" = "typescript";
      ".mustache" = "mustache";
      ".njk" = "njk";
      ".php" = "php";
      ".postcss" = "postcss";
      ".razor" = "razor";
      ".re" = "reason";
      ".res" = "rescript";
      ".sass" = "sass";
      ".scss" = "scss";
      ".slim" = "slim";
      ".sss" = "sugarss";
      ".styl" = "stylus";
      ".svelte" = "svelte";
      ".templ" = "templ";
      ".ts" = "typescript";
      ".tsx" = "typescriptreact";
      ".twig" = "twig";
      ".vue" = "vue";
      # keep-sorted end
    };
  in {
    programs.albedo.lsp = {
      enable = true;
      settings = {
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
            bin = getExe pkgs.roslyn-ls;
            # Albedo cannot send solution/open, so Roslyn discovers projects itself.
            args = [
              "--logLevel"
              "Information"
              "--extensionLogDirectory"
              "${config.xdg.cacheHome}/roslyn-ls/logs"
              "--stdio"
              "--autoLoadProjects"
            ];
            extensions = [
              # keep-sorted start
              ".cs"
              ".csx"
              ".vb"
              # keep-sorted end
            ];
            languageId = "csharp";
            languageIdByExtension = {
              # keep-sorted start
              ".cs" = "csharp";
              ".csx" = "csharp";
              ".vb" = "vb";
              # keep-sorted end
            };
          })

          (mkServer {
            id = "cssls";
            bin = getExe' pkgs.vscode-langservers-extracted "vscode-css-language-server";
            args = ["--stdio"];
            extensions = [
              # keep-sorted start
              ".css"
              ".less"
              # keep-sorted end
            ];
            languageIdByExtension = {
              # keep-sorted start
              ".css" = "css";
              ".less" = "less";
              # keep-sorted end
            };
            settings.css = {};
            rootMarkers = [
              # keep-sorted start
              ".git"
              "package.json"
              # keep-sorted end
            ];
          })

          (mkServer {
            id = "docker";
            bin = getExe pkgs.docker-language-server;
            args = [
              "start"
              "--stdio"
            ];
            # Albedo derives languageId from the suffix, so bare Dockerfile names get none.
            extensions = [".dockerfile"];
            languageId = "dockerfile";
          })

          (mkServer {
            id = "fish";
            bin = getExe pkgs.fish-lsp;
            args = ["start"];
            extensions = [".fish"];
            languageId = "fish";
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
              # keep-sorted start
              ".json" = "json";
              ".jsonc" = "jsonc";
              # keep-sorted end
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
            id = "phoxite";
            bin = getExe pkgs.nur.repos.adam0.phoxite;
            extensions = [
              # keep-sorted start
              ".php"
              ".twig"
              # keep-sorted end
            ];
            languageId = "php";
            languageIdByExtension = {
              # keep-sorted start
              ".php" = "php";
              ".twig" = "twig";
              # keep-sorted end
            };
            rootMarkers = [
              # keep-sorted start
              ".git"
              "composer.json"
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
            rootMarkers = [".git"];
            settings."rust-analyzer".check.command = "clippy";
          })

          (mkServer {
            id = "superhtml";
            bin = getExe pkgs.superhtml;
            args = ["lsp"];
            extensions = [
              # keep-sorted start
              ".html"
              ".xhtml"
              # keep-sorted end
            ];
            languageIdByExtension = {
              # keep-sorted start
              ".html" = "html";
              ".xhtml" = "xhtml";
              # keep-sorted end
            };
          })

          (mkServer {
            id = "tailwindcss";
            bin = getExe pkgs.tailwindcss-language-server;
            args = ["--stdio"];
            extensions = attrNames tailwindLanguages;
            languageIdByExtension = tailwindLanguages;
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
              ".cjs"
              ".cts"
              ".js"
              ".mjs"
              ".mts"
              ".ts"
              # keep-sorted end
            ];
            languageIdByExtension = {
              # keep-sorted start
              ".cjs" = "javascript";
              ".cts" = "typescript";
              ".js" = "javascript";
              ".mjs" = "javascript";
              ".mts" = "typescript";
              ".ts" = "typescript";
              # keep-sorted end
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
  };
}
