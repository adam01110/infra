{
  flake.aspects.albedo.homeManager = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe getExe';
    inherit (pkgs) writeShellApplication;

    # Project roots shared by every linter, after any tool-specific config file.
    gitRoots = [
      # keep-sorted start
      ".git"
      ".jj"
      # keep-sorted end
    ];

    # Deadnix only emits JSON, so flatten it to `file:line:column:endColumn: message`.
    deadnix = writeShellApplication {
      name = "deadnix-lines";
      runtimeInputs = [pkgs.deadnix pkgs.jq];
      text = ''
        deadnix --output-format=json "$@" | jq -r '
          .file as $file
          | .results[]
          | "\($file):\(.line):\(.column):\(.endColumn): \(.message)"
        '
      '';
    };

    linterSettings = {
      timeoutMs = 45000;
      linters = {
        # keep-sorted start block=yes newline_separated=yes
        biomejs = {
          command = [
            (getExe pkgs.biome)
            "lint"
            "--reporter=sarif"
          ];
          format = "sarif";
          rootMarkers = ["biome.json" "biome.jsonc"] ++ gitRoots;
        };

        deadnix = {
          command = [(getExe deadnix)];
          pattern = ''^(?P<path>[^:\n]+):(?P<line>\d+):(?P<column>\d+):(?P<endColumn>\d+): (?P<message>.*)$'';
        };

        hadolint = {
          command = [
            (getExe pkgs.hadolint)
            "--format"
            "sarif"
          ];
          format = "sarif";
        };

        htmlhint = {
          command = [
            (getExe pkgs.htmlhint)
            "--format"
            "sarif"
          ];
          format = "sarif";
        };

        ktlint = {
          command = [
            (getExe pkgs.ktlint)
            # Ktlint logs warnings on stdout, which would corrupt the report.
            "--log-level=none"
            "--reporter=sarif"
          ];
          format = "sarif";
        };

        mago_analyze = {
          command = [
            (getExe pkgs.mago)
            "--colors=never"
            "analyze"
            "--reporting-format=sarif"
          ];
          format = "sarif";
          rootMarkers = ["mago.toml"] ++ gitRoots;
        };

        mago_lint = {
          command = [
            (getExe pkgs.mago)
            "--colors=never"
            "lint"
            "--reporting-format=sarif"
          ];
          format = "sarif";
          rootMarkers = ["mago.toml"] ++ gitRoots;
        };

        mypy = {
          command = [
            (getExe' pkgs.mypy "mypy")
            "--show-column-numbers"
            "--show-error-end"
            "--hide-error-context"
            "--no-color-output"
            "--no-error-summary"
            "--no-pretty"
            # Linting stays read-only, so no .mypy_cache is written.
            "--cache-dir=/dev/null"
          ];
          pattern = ''^(?P<path>[^:\n]+):(?P<line>\d+):(?P<column>\d+):(?P<endLine>\d+):(?P<endColumn>\d+): (?P<severity>\w+): (?P<message>.*) \[(?P<code>[\w-]+)\]$'';
          rootMarkers = ["mypy.ini" "pyproject.toml" "setup.cfg"] ++ gitRoots;
        };

        selene = {
          command = [
            (getExe pkgs.selene)
            "--display-style=quiet"
            "--no-summary"
          ];
          pattern = ''^(?P<path>[^:\n]+):(?P<line>\d+):(?P<column>\d+): (?P<severity>\w+)\[(?P<code>[^\]]+)\]: (?P<message>.*)$'';
          rootMarkers = ["selene.toml"] ++ gitRoots;
        };

        shellcheck = {
          command = [
            (getExe pkgs.shellcheck)
            "--format"
            "gcc"
          ];
          pattern = ''^(?P<path>[^:\n]+):(?P<line>\d+):(?P<column>\d+): (?P<severity>\w+): (?P<message>.*?)(?: \[(?P<code>SC\d+)\])?$'';
        };

        statix = {
          command = [
            (getExe pkgs.statix)
            "check"
            "--format"
            "errfmt"
          ];
          pattern = ''^(?P<path>[^>\n]+)>(?P<line>\d+):(?P<column>\d+):(?P<severity>[EW]):(?P<code>\d+):(?P<message>.*)$'';
          rootMarkers = ["statix.toml"] ++ gitRoots;
        };
        # keep-sorted end
      };

      # Rumdl and tombi are skipped because lsp.nix already runs their servers.
      chains = {
        # keep-sorted start
        ".bash" = ["shellcheck"];
        ".dockerfile" = ["hadolint"];
        ".html" = ["htmlhint"];
        ".kt" = ["ktlint"];
        ".kts" = ["ktlint"];
        ".lua" = ["selene"];
        ".nix" = ["statix" "deadnix"];
        ".php" = ["mago_lint" "mago_analyze"];
        ".py" = ["mypy"];
        ".pyi" = ["mypy"];
        ".sh" = ["shellcheck"];
        ".ts" = ["biomejs"];
        "Dockerfile" = ["hadolint"];
        # keep-sorted end
      };
    };
  in {
    programs.albedo.linter = {
      enable = true;
      settings = linterSettings;
    };
  };
}
