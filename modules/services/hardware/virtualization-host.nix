{
  flake.modules.nixos.virtualizationHost = {vars, ...}: let
    inherit (vars) username;
  in {
    boot.kernelModules = ["kvm-intel"];

    users.users.${username}.extraGroups = ["kvm"];
  };
}
