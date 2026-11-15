{
  perSystem = {pkgs, ...}: {
    # Already uses Discord's current class format, so no substitutions are needed.
    packages.discord-bubble-usernames = pkgs.fetchurl {
      name = "bubbleUsernames.css";
      url = "https://raw.githubusercontent.com/yiruzu/vencord-snippets/b899b5d5c17429de07fd72b02f358fc8b3ea9584/snippets/BubbleUsernames/import.css";
      hash = "sha256-oFkV2X3XoBiXy6svhIOG1JxQ1XZ1Z5MAaRX+sQdh8QA=";
    };
  };
}
