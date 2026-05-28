{
  perSystem = {pkgs, ...}: {
    packages.man-preview = pkgs.writeShellApplication {
      name = "man-preview";
      runtimeInputs =
        [pkgs.bat]
        ++ (with pkgs; [
          # keep-sorted start
          gnused
          man-db
          # keep-sorted end
        ]);
      text = ''
        MANPAGER=cat MANROFFOPT=-c man "$1" \
          | sed -e 's/\x1B\[[0-9;]*m//g; s/.\x08//g' \
          | bat --language=man --plain --color=always
      '';
    };
  };
}
