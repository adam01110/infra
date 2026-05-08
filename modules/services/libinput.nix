{
  flake.modules.nixos.libinput = {
    # Input stack defaults (touchpad, mouse) via libinput.
    services.libinput.enable = true;
  };
}
