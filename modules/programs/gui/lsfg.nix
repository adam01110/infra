{
  flake.modules.nixos.lsfg = {pkgs, ...}: {
    # Add lossless scaling linux packages.
    environment.systemPackages = with pkgs; [
      # keep-sorted start
      lsfg-vk
      lsfg-vk-ui
      # keep-sorted end
    ];
  };
}
