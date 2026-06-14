{
  flake.modules.nixos.lsfg = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # keep-sorted start
      lsfg-vk
      lsfg-vk-ui
      # keep-sorted end
    ];
  };
}
