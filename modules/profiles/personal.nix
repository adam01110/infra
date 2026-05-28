{self, ...}: {
  flake.modules.nixos.personal = {config, ...}: {
    imports = with self.modules;
      [generic.determinate]
      ++ (with nixos; [
        base

        # keep-sorted start
        appimage
        hyprland
        java
        noctalia
        pipewire
        polkit
        power-profiles-daemon
        stylixPersonal
        tuigreet
        upower
        xdgPortal
        # keep-sorted end
      ]);

    disko.devices = (self.diskoConfigurations.ext4 config.disko.selectedDisk).disko.devices;
  };

  flake.modules.homeManager.personal = {
    imports = with self.modules.homeManager; [
      base

      # keep-sorted start
      env
      face
      git
      gtk
      hyprland
      nvtop
      # keep-sorted end
    ];
  };
}
