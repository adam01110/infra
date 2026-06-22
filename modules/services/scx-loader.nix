{
  flake.modules.nixos.scx = {pkgs, ...}: {
    services.scx-loader = {
      enable = true;
      schedsPackages = pkgs.scx.rustscheds;

      config = {
        default_sched = "scx_lavd";
        default_mode = "Auto";

        scheds.scx_lavd.auto_mode = ["--autopower"];
      };
    };
  };
}
