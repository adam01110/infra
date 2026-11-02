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
        antigravity.searchModel = "gemini-3.8-flash";
        claude.searchModel = "claude-haiku-5-5";
        codex.searchModel = "gpt-6-luna";

        enabled = {
          # keep-sorted start
          antigravity = true;
          artifacts = false;
          bedrock = true;
          claude = true;
          codex = true;
          exa = true;
          lcm = true;
          lcm-memory = true;
          mcp = true;
          mistral = true;
          models = true;
          notes = true;
          openai = true;
          opencode-go = true;
          opencode-zen = true;
          perplexity = true;
          rolling = false;
          snapcompact = false;
          snapcompact-memory = false;
          vertex = true;
          web-search = true;
          zed = true;
          # keep-sorted end
        };

        subagents = {
          # keep-sorted start
          maxDepth = 1;
          maxOpenChildren = 8;
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
