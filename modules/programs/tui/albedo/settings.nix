{
  flake.modules.homeManager.albedo = _: {
    programs.albedo = {
      activeProvider = "codex";

      providers.codex = {
        # keep-sorted start
        effort = null;
        extension = "codex";
        model = "gpt-6.1-sol";
        protocol = "responses";
        # keep-sorted end
      };

      showDiffs = false;
      settings = {
        enabled = {
          # keep-sorted start
          alibaba = false;
          antigravity = false;
          bedrock = false;
          claude = false;
          codex = true;
          exa = true;
          mcp = true;
          models = true;
          openai = true;
          vertex = false;
          web-search = true;
          # keep-sorted end
        };

        web-search = {
          # Search Codex first, then fall back to Exa.
          order = ["codex" "exa"];
          off = [
            # keep-sorted start
            "antigravity"
            "claude"
            # keep-sorted end
          ];
        };
      };
    };
  };
}
