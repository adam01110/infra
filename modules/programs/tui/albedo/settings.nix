{
  flake.aspects.albedo.homeManager = _: {
    programs.albedo = {
      activeProvider = "claude";

      providers = {
        claude = {
          effort = "medium";
          extension = "claude";
          model = "claude-opus-5-5";
          protocol = "chat_completions";
        };

        codex = {
          effort = "medium";
          extension = "codex";
          model = "gpt-6.1-sol";
          protocol = "responses";
        };
      };

      showDiffs = false;
      settings = {
        claude.searchModel = "claude-haiku-5-5";
        codex.searchModel = "gpt-6-luna";

        enabled = {
          # keep-sorted start
          antigravity = true;
          artifacts = false;
          bedrock = true;
          claude = true;
          codex = true;
          coding-lcm = true;
          exa = true;
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

        # Monitor freshness; Anthropic's usage endpoint 429s on faster polling.
        quota = {
          # keep-sorted start
          busyPollSeconds = 60;
          pollSeconds = 120;
          # keep-sorted end
        };

        subagents = {
          # keep-sorted start
          maxDepth = 1;
          maxOpenChildren = 8;
          # keep-sorted end
        };

        web-search = {
          order = ["codex" "claude" "exa"];
          off = ["antigravity" "perplexity"];
        };
      };
    };
  };
}
