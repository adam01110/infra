{
  flake.modules.homeManager.pi = {
    inputs,
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

    computerUseNodeArch =
      if pkgs.stdenv.hostPlatform.isx86_64
      then "x64"
      else if pkgs.stdenv.hostPlatform.isAarch64
      then "arm64"
      else throw "pi: unsupported computer-use-linux architecture";
    piSuite = inputs.pi-suite.packages.${pkgs.stdenv.hostPlatform.system}.default;

    mcpConfig = jsonFormat.generate "pi-mcp.json" {
      settings = {
        directTools = false;
        idleTimeout = 1;
      };

      mcpServers = {
        computer-use-linux = {
          args = ["mcp"];
          command = "${piSuite}/node_modules/@agent-sh/computer-use-linux/npm/bin/computer-use-linux-linux-${computerUseNodeArch}";
        };

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

      programs.pi.mcpServers = {
        inherit
          # keep-sorted start
          context7McpWrapper
          githubMcpServerWrapper
          tangledMcpWrapper
          # keep-sorted end
          ;
      };

      # Keep the declarative baseline writable for extensions that register servers.
      home.activation.writePiMcpConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${pkgs.coreutils}/bin/install -Dm600 ${mcpConfig} "$HOME/.pi/agent/mcp.json"
      '';
    };
  };
}
