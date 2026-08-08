{
  flake.modules.homeManager.pi = {
    programs.pi.coding-agent = {
      extensions = ["npm:pi-cc-header@1.0.2"];

      settings = {
        quietStartup = true;
        rsl = true;
        ccHeader = {
          color = "y";
          grad = true;
          lines = false;
          ver = 1;
        };
      };
    };
  };
}
