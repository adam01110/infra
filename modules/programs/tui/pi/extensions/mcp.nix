{
  flake.modules.homeManager.pi = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      escapeShellArg
      getExe
      mkOption
      types
      # keep-sorted end
      ;
    inherit (pkgs) writeShellApplication;

    jsonFormat = pkgs.formats.json {};

    # keep-sorted start block=yes newline_separated=yes
    context7McpWrapper = writeShellApplication {
      name = "context7-mcp-wrapper";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        CONTEXT7_API_KEY="$(cat "${config.sops.secrets."ai/context7_key".path}")"
        export CONTEXT7_API_KEY
        exec "${getExe pkgs.context7-mcp}" "$@"
      '';
    };

    githubMcpServerWrapper = writeShellApplication {
      name = "github-mcp-server-wrapper";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        GITHUB_PERSONAL_ACCESS_TOKEN="$(cat "${config.sops.secrets."ai/github_token".path}")"
        export GITHUB_PERSONAL_ACCESS_TOKEN
        exec "${getExe pkgs.github-mcp-server}" stdio "$@"
      '';
    };

    tangledMcpWrapper = writeShellApplication {
      name = "tangled-mcp-wrapper";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        TANGLED_HANDLE=${escapeShellArg vars.atprotoHandle}
        TANGLED_PASSWORD="$(cat "${config.sops.secrets."atproto_app_password".path}")"
        TANGLED_PDS_URL=${escapeShellArg "https://pds.${vars.groundDomain}"}
        export TANGLED_HANDLE TANGLED_PASSWORD TANGLED_PDS_URL
        exec "${getExe pkgs.nur.repos.adam0.tangled-mcp}" "$@"
      '';
    };
    # keep-sorted end
  in {
    options.programs.pi.mcpServers = mkOption {
      description = "MCP server packages added to the wrapped Pi launcher PATH.";

      type = types.attrsOf types.package;
      default = {};
    };

    config = {
      sops.secrets = {
        # keep-sorted start
        "ai/context7_key" = {};
        "ai/github_token" = {};
        "atproto_app_password" = {};
        # keep-sorted end
      };

      programs.pi = {
        coding-agent.extensions = ["npm:pi-mcp-adapter@2.11.0"];

        mcpServers = {
          inherit
            # keep-sorted start
            context7McpWrapper
            githubMcpServerWrapper
            tangledMcpWrapper
            # keep-sorted end
            ;
        };
      };

      home.file.".pi/agent/mcp.json".source = jsonFormat.generate "pi-mcp.json" {
        settings = {
          directTools = false;
          idleTimeout = 1;
        };

        mcpServers = {
          context7 = {
            command = "context7-mcp-wrapper";
            directTools = false;
            exposeResources = false;
            lifecycle = "lazy";
          };

          github = {
            command = "github-mcp-server-wrapper";
            directTools = false;
            exposeResources = false;
            lifecycle = "lazy";
          };

          tangled = {
            command = "tangled-mcp-wrapper";
            directTools = false;
            exposeResources = false;
            lifecycle = "lazy";
          };
        };
      };
    };
  };
}
