{
  flake.modules.homeManager.fish = {
    programs.fish.interactiveShellInitSnippets = [
      # Ghostty shapes ligatures within a single color run, so the redirection
      # color must match the parameter color for `->` and `=>` to ligate.
      ''
        set -g fish_color_redirection $fish_color_param
      ''
    ];
  };
}
