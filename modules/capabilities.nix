{lib, ...}: {
  flake.aspects.capabilities.nixos.options.capabilities.gpuVram =
    lib.mkEnableOption "GPU VRAM monitoring support";
}
