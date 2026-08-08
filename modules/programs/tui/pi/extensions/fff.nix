{
  flake.modules.homeManager.pi = {
    programs.pi.coding-agent = {
      extensions = ["npm:@ff-labs/pi-fff@0.10.3"];

      environment.PI_FFF_MODE.value = "override";
    };
  };
}
