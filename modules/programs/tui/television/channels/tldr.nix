{
  flake.modules.homeManager.television = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;

    tldr = getExe pkgs.tlrc;
  in {
    programs.television.channels.tldr = {
      # keep-sorted start block=yes newline_separated=yes
      actions.open = {
        description = "Open the selected TLDR page";
        command = "${tldr} '{0}'";
        mode = "execute";
      };

      keybindings.ctrl-e = "actions:open";

      metadata = {
        name = "tldr";
        description = "Browse and preview TLDR help pages for command-line tools";
        requirements = ["tldr"];
      };

      preview.command = "${tldr} '{0}' --color always";

      source.command = "${tldr} --list";
      # keep-sorted end
    };
  };
}
