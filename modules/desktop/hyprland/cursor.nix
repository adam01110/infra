{
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
    home = {
      # Hyprcursor variant of the configured Bibata cursor package.
      packages = [pkgs.nur.repos.adam0.bibata-modern-cursors-gruvbox-dark-hyprcursor];

      # Match the hyprcursor package suffix.
      sessionVariables.HYPRCURSOR_THEME = mkForce "${config.stylix.cursor.name}-hyprcursor";
    };

    home.pointerCursor.hyprcursor.enable = true;
  };
}
