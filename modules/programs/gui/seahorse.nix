{
  flake.modules.homeManager.seahorse = {
    dconf.settings."apps/seahorse/listing".item-filter = "any";
  };

  flake.modules.nixos.seahorse = {
    programs.seahorse.enable = true;
  };
}
