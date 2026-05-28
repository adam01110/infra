{
  flake.modules.nixos.vm = {
    # keep-sorted start
    self,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) username;
  in {
    home-manager.users.${username} = {
      imports = with self.modules.homeManager; [
        # keep-sorted start
        personal
        # keep-sorted end
      ];

      # keep-sorted start block=yes newline_separated=yes
      # Configure the vm display settings.
      programs.nixhypr.monitors = [
        {
          output = "Virtual-1";
          mode = "1920x1080@60";
          position = "0x0";
          scale = "1";
          extra.vrr = 0;
        }
      ];

      # Browser memory allocation for vm environment.
      programs.zen-browser.profiles.default.preferences.commitSpace = 6683;
      # keep-sorted end
    };
  };
}
