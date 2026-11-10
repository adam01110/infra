{
  flake-file.inputs.bootvine = {
    url = "git+https://codeberg.org/wvhulle/bootvine";

    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.bootvine = {inputs, ...}: {
    imports = [inputs.bootvine.nixosModules.bootvine];

    # Show a live systemd job tree on the boot and shutdown console.
    services.bootvine.enable = true;
  };
}
