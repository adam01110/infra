{
  flake.aspects.albedo.homeManager = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) attrValues;
    inherit
      (lib)
      # keep-sorted start
      concatMap
      elem
      genAttrs
      getExe
      getExe'
      mapAttrs
      unique
      # keep-sorted end
      ;
    inherit (pkgs) writeShellApplication;

    # mcp-proxy 0.13 requires the MCP 1.x SDK.
    mcpProxy = pkgs.mcp-proxy.override {
      python3Packages = pkgs.python3Packages // {mcp = pkgs.python3Packages.mcp_1;};
    };

    mcps = {
      # keep-sorted start block=yes newline_separated=yes
      canvas = {
        description = "Canvas coursework: courses, assignments, submissions and grades.";
        command = getExe pkgs.nur.repos.adam0.canvas-api-mcp;
        secrets = {
          # keep-sorted start
          CANVAS_BASE_URL = "ai/canvas_base_url";
          CANVAS_TOKEN = "ai/canvas_token";
          # keep-sorted end
        };
      };

      context7 = {
        description = "Current library documentation and examples.";
        command = getExe pkgs.context7-mcp;
        secrets.CONTEXT7_API_KEY = "ai/context7_key";
      };

      deckcraft = {
        description = "Read, create and edit slide decks (.pptx).";
        args = ["mcp"];
        command = getExe' pkgs.deckcraft "deckcraft-cli";
      };

      excalidash = {
        description = "Create and edit diagrams and whiteboards.";
        command = getExe pkgs.nur.repos.adam0.excalidash-mcp;
        environment = {
          # keep-sorted start
          EXCALIDASH_BACKEND_URL = "https://excalidash.${vars.groundDomain}/api";
          EXCALIDASH_URL = "https://excalidash.${vars.groundDomain}";
          # keep-sorted end
        };
        secrets.EXCALIDASH_API_KEY = "ai/excalidash_key";
      };

      figma = {
        description = "Read and edit open Figma files.";
        # Starts the shared relay on first use rather than at login.
        command = getExe (writeShellApplication {
          name = "figma-mcp";
          runtimeInputs = [pkgs.systemd];
          # Albedo starts servers without XDG_RUNTIME_DIR, which systemctl --user needs.
          text = ''
            export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$UID}"
            systemctl --user start talk-to-figma-relay.service
            exec ${getExe pkgs.nur.repos.adam0.talk-to-figma-mcp}
          '';
        });
      };

      github = {
        description = "GitHub repositories, issues, pull requests and Actions.";
        args = ["stdio"];
        command = getExe pkgs.github-mcp-server;
        secrets.GITHUB_PERSONAL_ACCESS_TOKEN = "ai/github_token";
      };

      gitlab = {
        description = "College GitLab forge: repositories, issues, merge requests and CI.";
        args = ["mcp" "serve"];
        command = getExe pkgs.glab;
        secrets = {
          # keep-sorted start
          GITLAB_HOST = "git/college_forge/host";
          GITLAB_TOKEN = "ai/gitlab_token";
          # keep-sorted end
        };
      };

      gridcraft = {
        description = "Read, create and edit spreadsheets (.xlsx, .ods).";
        args = ["mcp"];
        command = getExe' pkgs.gridcraft "gridcraft-cli";
      };

      pdfcraft = {
        description = "Read, create and edit PDFs: pages, text, forms, comments, OCR.";
        args = ["mcp"];
        command = getExe' pkgs.pdfcraft "pdfcraft-cli";
      };

      penpot = {
        description = "Penpot designs: inspect, edit and export pages and shapes.";
        command = getExe (writeShellApplication {
          name = "penpot-mcp";
          runtimeInputs = [
            # keep-sorted start
            mcpProxy
            pkgs.jq
            # keep-sorted end
          ];
          # Penpot 2.19 reads the key only from the userToken query; keep it out of argv and logs.
          text = ''
            export SSE_URL
            SSE_URL="https://penpot.${vars.groundDomain}/mcp/stream?userToken=$(jq -rn 'env.PENPOT_MCP_KEY | trim | @uri')"
            unset PENPOT_MCP_KEY
            # INFO logs every request URL, including the token.
            exec mcp-proxy --log-level WARNING --transport streamablehttp
          '';
        });
        secrets.PENPOT_MCP_KEY = "ai/penpot_key";
      };

      rea = {
        description = "Reverse engineering: binaries, applications, runtime behavior.";
        # Analysis engines come from the session PATH, not runtime inputs.
        args = ["mcp"];
        command = getExe pkgs.nur.repos.silicalet.rea;
        # Keep advertised schemas compact across roughly 200 tools.
        environment.REA_MCP_INPUT_SCHEMA_PROFILE = "compact";
      };

      tangled = {
        description = "Personal Tangled repositories, issues, pulls and pipelines.";
        command = getExe' pkgs.nur.repos.adam0.tg "tgmcp";
        environment.TGMCP_ACCOUNT = vars.atprotoHandle;
      };

      wordcraft = {
        description = "Read, create and edit documents (.docx, .odt, .rtf).";
        args = ["mcp"];
        command = getExe' pkgs.wordcraft "wordcraft-cli";
      };
      # keep-sorted end
    };

    # These hold an open document, channel or session in the server process, which idle cleanup would discard.
    stateful = [
      # keep-sorted start
      "deckcraft"
      "figma"
      "gridcraft"
      "pdfcraft"
      "penpot"
      "rea"
      "wordcraft"
      # keep-sorted end
    ];

    secretNames = unique (concatMap (mcp: attrValues (mcp.secrets or {})) (attrValues mcps));
  in {
    sops.secrets = genAttrs secretNames (_: {});

    # The Talk to Figma plugin and MCP server meet on this relay at 127.0.0.1:3055.
    systemd.user.services.talk-to-figma-relay = {
      Unit.Description = "Talk to Figma WebSocket relay";
      Service = {
        ExecStart = getExe' pkgs.nur.repos.adam0.talk-to-figma-mcp "talk-to-figma-relay";
        Restart = "on-failure";
      };
    };

    programs.albedo.mcp = {
      enable = true;
      lazy = true;
      servers =
        mapAttrs (name: mcp: {
          inherit (mcp) command;
          description = mcp.description or "";
          idleTimeoutMs =
            if elem name stateful
            then 0
            else null;
          args = mcp.args or [];
          environment = mcp.environment or {};
          secretFiles = mapAttrs (_: secret: config.sops.secrets.${secret}.path) (mcp.secrets or {});
        })
        mcps;
    };
  };
}
