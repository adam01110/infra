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
        description = "Canvas coursework.";
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
        command = getExe (writeShellApplication {
          name = "figma-mcp";
          runtimeInputs = [pkgs.nodejs];
          text = ''
            exec npx --yes mcp-remote@0.16.0 https://mcp.figma.com/mcp
          '';
        });
      };

      github = {
        args = ["stdio"];
        command = getExe pkgs.github-mcp-server;
        secrets.GITHUB_PERSONAL_ACCESS_TOKEN = "ai/github_token";
      };

      gitlab = {
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
        description = "Edit spreadsheets.";
        args = ["mcp"];
        command = getExe' pkgs.gridcraft "gridcraft-cli";
      };

      penpot = {
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
        description = "Manage Tangled Git repositories, issues and pipelines.";
        command = getExe' pkgs.nur.repos.adam0.tg "tgmcp";
        environment.TGMCP_ACCOUNT = vars.atprotoHandle;
      };

      wordcraft = {
        description = "Edit documents.";
        args = ["mcp"];
        command = getExe' pkgs.wordcraft "wordcraft-cli";
      };

      deckcraft = {
        description = "Edit slide decks.";
        args = ["mcp"];
        command = getExe' pkgs.deckcraft "deckcraft-cli";
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
          inherit (mcp) command;
          description = mcp.description or "";
          args = mcp.args or [];
          environment = mcp.environment or {};
          secretFiles = mapAttrs (_: secret: config.sops.secrets.${secret}.path) (mcp.secrets or {});
        })
        mcps;
    };
  };
}
