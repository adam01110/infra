{
  flake.modules.nixos = {
    libinput.services.libinput.enable = true;

    roccat = {
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
  };
}
