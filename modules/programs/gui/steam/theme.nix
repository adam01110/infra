{
  flake.modules.homeManager.steam = {pkgs, ...}: let
    inherit (pkgs) fetchFromGitHub;
  in {
    programs.steam.millennium = {
      activeTheme = "adwaita";

      config.themes.conditions.adwaita = {
        "Color theme" = "Gruvbox";

        # keep-sorted start
        "Accent color" = "System";
        "Color scheme" = "System";
        Font = "System";
        # keep-sorted end

        # keep-sorted start
        "Hide games list" = "no";
        "Login QR code" = "Show";
        "Pointer cursor" = "no";
        "Rounded corners" = "no";
        "Show URL" = "yes";
        "Square icons in game details" = "yes";
        "What's New shelf" = "yes";
        "Window controls layout" = "Adwaita";
        "Window controls theme" = "Adwaita (GNOME)";
        # keep-sorted end
      };

      themes.adwaita = fetchFromGitHub {
        owner = "tkashkin";
        repo = "Adwaita-for-Steam";
        rev = "1e92107a51f6ed53c59c38646444c9eb3a52b030";
        hash = "sha256-wH0z2LZ94j5ErRI40f9IRBJXJ6yuL+NLgjmj9G8odxU=";
      };
    };
  };
}
