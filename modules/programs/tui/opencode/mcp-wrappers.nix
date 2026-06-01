{
  flake.modules.homeManager.opencode = {
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
      getExe
      mkOption
      types
      # keep-sorted end
      ;
    inherit (pkgs) writeShellApplication;

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
        exec "${getExe pkgs.github-mcp-server}" stdio --read-only "$@"
      '';
    };
    # keep-sorted end
  in {
    options.programs.opencode.mcpServers = mkOption {
      description = "MCP server packages added to the wrapped opencode launcher PATH.";

      type = types.attrsOf types.package;
      default = {};
    };

    config = {
      sops.secrets = {
        # keep-sorted start
        "ai/context7_key" = {};
        "ai/github_token" = {};
        # keep-sorted end
      };

      programs.opencode.mcpServers = {
        inherit
          # keep-sorted start
          context7McpWrapper
          githubMcpServerWrapper
          # keep-sorted end
          ;
      };
    };
  };
}
