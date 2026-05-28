{
  flake.modules.homeManager.discord = {
    programs.nixcord.config.plugins = {
      # keep-sorted start block=yes newline_separated=yes
      dragify.enable = true;

      gitHubRepos.enable = true;

      openInApp = {
        enable = true;
      };

      replaceGoogleSearch = {
        customEngineName = "Brave";
        customEngineURL = "https://search.brave.com/search?q=";
        enable = true;
        replacementEngine = "custom";
      };

      reverseImageSearch.enable = true;

      unitConverter = {
        enable = true;
        myUnits = "metric";
      };
      # keep-sorted end
    };
  };
}
