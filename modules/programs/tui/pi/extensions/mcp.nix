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
      (builtins)
      # keep-sorted start
      attrNames
      attrValues
      # keep-sorted end
      ;
    inherit
      (lib)
      # keep-sorted start
      concatMap
      concatStringsSep
      escapeShellArg
      escapeShellArgs
      genAttrs
      getExe
      mapAttrs
      mapAttrsToList
      mkOption
      optional
      optionalString
      types
      unique
      # keep-sorted end
      ;
    inherit
      (pkgs)
      # keep-sorted start
      coreutils
      writeShellApplication
      # keep-sorted end
      ;

    jsonFormat = pkgs.formats.json {};

    computerUseNodeArch =
      if pkgs.stdenv.hostPlatform.isx86_64
      then "x64"
      else if pkgs.stdenv.hostPlatform.isAarch64
      then "arm64"
      else throw "pi: unsupported computer-use-linux architecture";
    piSuite = inputs.pi-suite.packages.${pkgs.stdenv.hostPlatform.system}.default;

    mkMcp = {
      args ? [],
      command,
      environment ? {},
      name,
      secrets ? {},
    }: let
      environmentNames = attrNames (environment // secrets);
      wrapperName = "${name}-mcp-wrapper";
      package = writeShellApplication {
        name = wrapperName;
        runtimeInputs = [coreutils];
        text = concatStringsSep "\n" (
          (mapAttrsToList (variable: value: "${variable}=${escapeShellArg value}") environment)
          ++ (mapAttrsToList (
              variable: secretName: ''${variable}="$(cat ${escapeShellArg config.sops.secrets.${secretName}.path})"''
            )
            secrets)
          ++ optional (environmentNames != []) "export ${concatStringsSep " " environmentNames}"
          ++ ["exec ${escapeShellArg command}${optionalString (args != []) " ${escapeShellArgs args}"} \"$@\""]
        );
      };
    in {
      inherit package;
      secretNames = attrValues secrets;
      server = {
        approveTools = false;
        command = wrapperName;
        directTools = false;
        exposeResources = false;
        lifecycle = "lazy";
      };
    };

    mcps = mapAttrs (name: mcp: mkMcp (mcp // {inherit name;})) {
      # keep-sorted start block=yes newline_separated=yes
      computer-use-linux = {
        args = ["mcp"];
        command = "${piSuite}/node_modules/@agent-sh/computer-use-linux/npm/bin/computer-use-linux-linux-${computerUseNodeArch}";
      };

      context7 = {
        command = getExe pkgs.context7-mcp;

        secrets.CONTEXT7_API_KEY = "ai/context7_key";
      };

      excalidash = {
        command = getExe pkgs.nur.repos.adam0.excalidash-mcp;

        environment.EXCALIDASH_URL = "https://excalidash.${vars.groundDomain}";

        secrets.EXCALIDASH_API_KEY = "ai/excalidash_key";
      };

      github = {
        args = ["stdio"];
        command = getExe pkgs.github-mcp-server;

        secrets.GITHUB_PERSONAL_ACCESS_TOKEN = "ai/github_token";
      };

      tangled = {
        command = getExe pkgs.nur.repos.adam0.tangled-mcp;

        environment = {
          TANGLED_HANDLE = vars.atprotoHandle;
          TANGLED_PDS_URL = "https://pds.${vars.groundDomain}";
        };

        secrets.TANGLED_PASSWORD = "atproto_app_password";
      };
      # keep-sorted end
    };

    mcpConfig = jsonFormat.generate "pi-mcp.json" {
      settings = {
        approveTools = false;
        directTools = false;
        idleTimeout = 1;
      };

      mcpServers = mapAttrs (_: mcp: mcp.server) mcps;
    };

    mcpSecretNames = unique (concatMap (mcp: mcp.secretNames) (attrValues mcps));
  in {
    options.programs.pi.mcpServers = mkOption {
      description = "MCP server packages added to the wrapped Pi launcher PATH.";

      type = types.attrsOf types.package;
      default = {};
    };

    config = {
      sops.secrets = genAttrs mcpSecretNames (_: {});

      programs.pi.mcpServers = mapAttrs (_: mcp: mcp.package) mcps;

      # Keep the declarative baseline writable for extensions that register servers.
      home.activation.writePiMcpConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${pkgs.coreutils}/bin/install -Dm600 ${mcpConfig} "$HOME/.pi/agent/mcp.json"
      '';
    };
  };
}
