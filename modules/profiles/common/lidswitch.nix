{
  # Lid switch behavior: suspend on close, ignore when docked.
  flake.aspects.lidswitch.nixos.services.logind.settings.Login = {
    # keep-sorted start
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "suspend";
    # keep-sorted end
  };
}
