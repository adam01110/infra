{
  flake.modules.homeManager.gtk = {config, ...}: {
    gtk.gtk4.theme = config.gtk.theme;

    dconf.settings = {
      # keep-sorted start
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/desktop/interface".gtk-enable-primary-paste = false;
      "org/gnome/desktop/wm/preferences".button-layout = "";
      # keep-sorted end
    };

    stylix.targets.gtk.extraCss = ''
      * { border-radius: 0px; }
      *::before { border-radius: 0px; }
      *::after { border-radius: 0px; }
    '';
  };
}
