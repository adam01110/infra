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
        command = getExe pkgs.nur.repos.adam0.canvas-api-mcp;
        secrets = {
          # keep-sorted start
          CANVAS_BASE_URL = "ai/canvas_base_url";
          CANVAS_TOKEN = "ai/canvas_token";
          # keep-sorted end
        };
      };

      context7 = {
        command = getExe pkgs.context7-mcp;
        secrets.CONTEXT7_API_KEY = "ai/context7_key";
      };

      excalidash = {
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
        args = ["stdio"];
        command = getExe pkgs.github-mcp-server;
        secrets.GITHUB_PERSONAL_ACCESS_TOKEN = "ai/github_token";
      };

      gridcraft = {
        args = ["mcp"];
        command = getExe' pkgs.nur.repos.quriosity.gridcraft "gridcraft-cli";
      };

      penpot = {
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
        command = getExe' pkgs.nur.repos.adam0.tg "tgmcp";
        environment.TGMCP_ACCOUNT = vars.atprotoHandle;
      };

      wordcraft = {
        args = ["mcp"];
        command = getExe' pkgs.nur.repos.quriosity.wordcraft "wordcraft-cli";
      };

      deckcraft = {
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
          inherit (mcp) command;
          args = mcp.args or [];
          environment = mcp.environment or {};
          secretFiles = mapAttrs (_: secret: config.sops.secrets.${secret}.path) (mcp.secrets or {});
        })
        mcps;
    };
  };
}
