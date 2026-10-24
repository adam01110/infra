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

    mcps = {
      # keep-sorted start block=yes newline_separated=yes
      canvas = {
        description = "Load when a coursework question requires the user's actual Canvas assignments, deadlines, grades or course materials; not for general study help.";
        command = getExe pkgs.nur.repos.adam0.canvas-api-mcp;
        secrets = {
          # keep-sorted start
          CANVAS_BASE_URL = "ai/canvas_base_url";
          CANVAS_TOKEN = "ai/canvas_token";
          # keep-sorted end
        };
      };

      context7 = {
        description = "Load when implementing or debugging against a library or framework requires current API documentation or version-specific examples.";
        command = getExe pkgs.context7-mcp;
        secrets.CONTEXT7_API_KEY = "ai/context7_key";
      };

      excalidash = {
        description = "Load when the user wants a diagram or whiteboard created or changed on ExcaliDash, including architecture, flow and sequence diagrams.";
        command = getExe pkgs.nur.repos.adam0.excalidash-mcp;
        environment = {
          # keep-sorted start
          EXCALIDASH_BACKEND_URL = "https://excalidash.${vars.groundDomain}/api";
          EXCALIDASH_URL = "https://excalidash.${vars.groundDomain}";
          # keep-sorted end
        };
        secrets.EXCALIDASH_API_KEY = "ai/excalidash_key";
      };

      github = {
        description = "Load when a task requires GitHub-hosted issue, pull request or review information or changes; not for ordinary edits in a local checkout.";
        args = ["stdio"];
        command = getExe pkgs.github-mcp-server;
        secrets.GITHUB_PERSONAL_ACCESS_TOKEN = "ai/github_token";
      };

      gridcraft = {
        description = "Load when the user wants a spreadsheet created or changed, or needs calculations, analysis or charts in a spreadsheet rather than a chat table.";
        args = ["mcp"];
        command = getExe' pkgs.nur.repos.quriosity.gridcraft "gridcraft-cli";
      };

      penpot = {
        description = "Load when the user asks to inspect or change a Penpot design, extract its assets, or implement a UI from an existing Penpot design.";
        command = getExe (writeShellApplication {
          name = "penpot-mcp";
          runtimeInputs = with pkgs; [
            # keep-sorted start
            mcp-proxy
            python3
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
        description = "Load when a task requires Tangled-hosted repository, issue or pipeline information or changes; not for ordinary edits in a local checkout.";
        command = getExe' pkgs.nur.repos.adam0.tg "tgmcp";
        environment.TGMCP_ACCOUNT = vars.atprotoHandle;
      };

      wordcraft = {
        description = "Load when the user wants a document file created or revised, or an existing document imported or exported; not for a prose answer in chat.";
        args = ["mcp"];
        command = getExe' pkgs.nur.repos.quriosity.wordcraft "wordcraft-cli";
      };

      deckcraft = {
        description = "Load when the user wants a slide deck created or revised, or an existing presentation imported or exported; not for an outline in chat.";
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
