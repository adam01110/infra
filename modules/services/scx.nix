{
  flake.modules.nixos.scx = {pkgs, ...}: {
    services.scx = {
      enable = true;

      # Use the rust scheds package with lavd and autopower tuning.
      package = pkgs.scx.rustscheds;
      scheduler = "scx_lavd";
      extraArgs = ["--autopower"];
    };
  };
}
