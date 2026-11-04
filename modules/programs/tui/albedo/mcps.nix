{
  flake.modules.homeManager.albedo = {
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
        description = "Access Canvas assignments, deadlines, grades and course materials.";
        command = getExe pkgs.nur.repos.adam0.canvas-api-mcp;
        secrets = {
          # keep-sorted start
          CANVAS_BASE_URL = "ai/canvas_base_url";
          CANVAS_TOKEN = "ai/canvas_token";
          # keep-sorted end
        };
      };

      context7 = {
        description = "Look up current library documentation and version-specific examples.";
        command = getExe pkgs.context7-mcp;
        secrets.CONTEXT7_API_KEY = "ai/context7_key";
      };

      excalidash = {
        description = "Create and edit diagrams and whiteboards in ExcaliDash.";
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
        description = "Inspect Figma designs, extract assets and generate implementation context.";
        command = getExe (writeShellApplication {
          name = "figma-mcp";
          runtimeInputs = [pkgs.nodejs];
          text = ''
            exec npx --yes mcp-remote@0.16.0 https://mcp.figma.com/mcp
          '';
        });
      };

      github = {
        description = "Manage GitHub issues, pull requests and reviews.";
        args = ["stdio"];
        command = getExe pkgs.github-mcp-server;
        secrets.GITHUB_PERSONAL_ACCESS_TOKEN = "ai/github_token";
      };

      gitlab = {
        description = "Manage GitLab projects, issues, merge requests and pipelines.";
        args = ["mcp" "serve"];
        command = getExe pkgs.glab;
        secrets.GITLAB_TOKEN = "ai/gitlab_token";
      };

      gridcraft = {
        description = "Create and edit spreadsheets, formulas and charts.";
        args = ["mcp"];
        command = getExe' pkgs.nur.repos.quriosity.gridcraft "gridcraft-cli";
      };

      penpot = {
        description = "Inspect and edit Penpot designs and extract assets.";
        command = getExe (writeShellApplication {
          name = "penpot-mcp";
          runtimeInputs = [
            # keep-sorted start
            mcpProxy
            pkgs.python3
            # keep-sorted end
          ];
          text = ''
            export SSE_URL
            SSE_URL="$(python3 - <<'PY'
            import os
            import urllib.parse

            key = os.environ.get("PENPOT_MCP_KEY", "").strip()
            print("https://penpot.${vars.groundDomain}/mcp/stream?userToken=" + urllib.parse.quote(key, safe=""))
            PY
            )"
            exec mcp-proxy --transport streamablehttp
          '';
        });
        secrets.PENPOT_MCP_KEY = "ai/penpot_key";
      };

      tangled = {
        description = "Manage Tangled repositories, issues and pipelines.";
        command = getExe' pkgs.nur.repos.adam0.tg "tgmcp";
        environment.TGMCP_ACCOUNT = vars.atprotoHandle;
      };

      wordcraft = {
        description = "Create, edit, import and export document files.";
        args = ["mcp"];
        command = getExe' pkgs.nur.repos.quriosity.wordcraft "wordcraft-cli";
      };

      deckcraft = {
        description = "Create, edit, import and export slide decks.";
        args = ["mcp"];
        command = getExe' pkgs.nur.repos.quriosity.deckcraft "deckcraft-cli";
      };
      # keep-sorted end
    };

    secretNames = unique (concatMap (mcp: attrValues (mcp.secrets or {})) (attrValues mcps));
  in {
    sops.secrets = genAttrs secretNames (_: {});
    programs.albedo.mcp = {
      enable = true;
      lazy = true;
      servers =
        mapAttrs (_: mcp: {
          inherit (mcp) command description;
          args = mcp.args or [];
          environment = mcp.environment or {};
          secretFiles = mapAttrs (_: secret: config.sops.secrets.${secret}.path) (mcp.secrets or {});
        })
        mcps;
    };
  };
}
