{self, ...}: {
  flake.modules.nixos.virtManager = {
    # keep-sorted start
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) username;
  in {
    imports = [self.modules.nixos.virtualizationHost];

    programs.virt-manager.enable = true;

    users.users.${username}.extraGroups = ["libvirtd"];

    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };

    # Trusts the default libvirt bridge and keeps NetworkManager from managing it.
    networking = let
      interface = ["virbr0"];
    in {
      firewall.trustedInterfaces = interface;
      networkmanager.unmanaged = interface;
    };
  };
}
