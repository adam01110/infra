{
  flake.modules.homeManager.polkit = {
    services.polkit-gnome.enable = true;
  };

  flake.modules.nixos.polkit = {
    security.polkit.enable = true;
  };
}
