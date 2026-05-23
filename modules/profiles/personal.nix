{self, ...}: {
  flake.modules.nixos.personal = {config, ...}: {
    imports =
      (with self.modules.nixos; [
        # keep-sorted start
        capabilities
        disko
        tmp
        # keep-sorted end

        # Profile common.
        # keep-sorted start
        home-manager
        locale
        slim
        stylixPersonal
        timezone
        tweaks
        users
        # keep-sorted end
      ])
      ++ [self.modules.generic.determinate];

    disko.devices = (self.diskoConfigurations.ext4 config.disko.disk).disko.devices;
  };

  flake.modules.homeManager.personal = {
    imports = with self.modules.homeManager; [
      # Profile common.
      # keep-sorted start
      env
      face
      git
      gtk
      # keep-sorted end
    ];
  };
}
