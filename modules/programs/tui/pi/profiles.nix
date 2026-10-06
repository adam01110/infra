{
  flake.modules.homeManager.pi = {pkgs, ...}: let
    jsonFormat = pkgs.formats.json {};

    profiles = {
      "deepseek-v4.1" = {
        session = {
          model = "opencode-go/deepseek-v4.1-flash";
          thinking = "high";
        };

        # keep-sorted start
        coder.thinking = "high";
        fast.thinking = "low";
        worker.thinking = "high";
        # keep-sorted end
      };

      "glm-5.3" = {
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

      "kimi-k2.7" = {
        session = {
          model = "opencode-go/kimi-k2.7-code";
          thinking = "medium";
        };

        # keep-sorted start
        coder.thinking = "medium";
        fast.thinking = "low";
        worker.thinking = "medium";
        # keep-sorted end
      };

      "mimo-v2.6" = {
        session = {
          model = "opencode-go/mimo-v2.6-flash";
          thinking = "medium";
        };

        # keep-sorted start
        coder.thinking = "medium";
        fast.thinking = "low";
        worker.thinking = "medium";
        # keep-sorted end
      };

      minimax-m3 = {
        session = {
          model = "opencode-go/minimax-m3";
          thinking = "medium";
        };

        # keep-sorted start
        coder.thinking = "medium";
        fast.thinking = "low";
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
