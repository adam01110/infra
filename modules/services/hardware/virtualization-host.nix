{
  flake.aspects.virtualizationHost.nixos = {vars, ...}: let
    inherit (vars) username;
  in {
    boot.kernelModules = ["kvm-intel"];

    users.users.${username}.extraGroups = ["kvm"];
  };
}
