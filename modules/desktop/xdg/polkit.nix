{
  flake.modules.homeManager.polkit = _: {
    services.polkit-gnome.enable = true;
  };

  flake.modules.nixos.polkit = _: {
    security.polkit.enable = true;
  };
}
