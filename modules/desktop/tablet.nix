{
  flake.modules.nixos.tablet.hardware = {
    # keep-sorted start newline_separated=yes
    opentabletdriver.enable = true;

    # Required by opentabletdriver.
    uinput.enable = true;
    # keep-sorted end
  };
}
