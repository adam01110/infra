{
  flake.modules.nixos.libinput = {
    # Input stack defaults (touchpad, mouse) via libinput.
    services.libinput.enable = true;
  };

  flake.modules.nixos.roccat = {
    environment.etc."libinput/local-overrides.quirks" = let
      name = "ROCCAT ROCCAT Kain 100";
    in {
      text = ''
        [${name}]
        MatchName=${name}
        ModelBouncingKeys=1
      '';
      mode = "0644";
      user = "root";
      group = "root";
    };
  };
}
