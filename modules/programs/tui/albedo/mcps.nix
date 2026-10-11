{
  flake.modules.homeManager.albedo = {
    config,
    lib,
    pkgs,
    vars,
    ...
  }: let
    inherit (builtins) attrValues;
    inherit (lib) concatMap genAttrs getExe getExe' mapAttrs unique;

    mcps = {
      # keep-sorted start block=yes newline_separated=yes
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
        command = getExe' pkgs.nur.repos.adam0.tg "tgmcp";
        environment.TGMCP_ACCOUNT = vars.atprotoHandle;
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
