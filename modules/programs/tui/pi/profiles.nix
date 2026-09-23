{
  flake.modules.homeManager.pi = {pkgs, ...}: let
    jsonFormat = pkgs.formats.json {};

    profiles = {
      codex = {
        session = {
          model = "openai-codex/gpt-6-sol";
          thinking = "medium";
        };

        coder = {
          model = "openai-codex/gpt-6-sol";
          thinking = "medium";
        };

        fast = {
          model = "openai-codex/gpt-6-luna";
          thinking = "medium";
        };

        worker = {
          model = "openai-codex/gpt-6-sol";
          thinking = "low";
        };
      };

      go-glm = {
        session = {
          model = "opencode-go/glm-5.3-flash";
          thinking = "high";
        };

        # keep-sorted start
        coder.thinking = "high";
        fast.thinking = "low";
        worker.thinking = "high";
        # keep-sorted end
      };

      go-deepseek = {
        session = {
          model = "opencode-go/deepseek-v4.1-flash";
          thinking = "high";
        };

        # keep-sorted start
        coder.thinking = "high";
        fast.thinking = "off";
        worker.thinking = "high";
        # keep-sorted end
      };
    };
  in {
    # Read-only config; the suite's glue only reads it.
    home.file.".pi/agent/pi-profile-agents.json".source =
      jsonFormat.generate "pi-profile-agents.json" profiles;
  };
}
