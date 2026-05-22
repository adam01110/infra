{self, ...}: {
  flake.modules.homeManager.hyprland = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;
  in {
    imports = with self.modules.homeManager; [
      # keep-sorted start
      nur
      stylixPersonal
      # keep-sorted end
    ];

    # Install and export the Hyprcursor theme selected by Stylix.
    home = {
      # Hyprcursor variant of the configured Bibata cursor package.
      packages = [pkgs.nur.repos.adam0.bibata-modern-cursors-gruvbox-dark-hyprcursor];

      # Match the hyprcursor package suffix.
      sessionVariables.HYPRCURSOR_THEME = mkForce "${config.stylix.cursor.name}-hyprcursor";
    };

    # Let Home Manager link Hyprcursor assets.
    home.pointerCursor.hyprcursor.enable = true;
  };
}
