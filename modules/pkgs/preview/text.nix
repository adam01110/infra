{
  perSystem = {pkgs, ...}: {
    packages.text-preview = pkgs.writeShellApplication {
      name = "text-preview";
      runtimeInputs = with pkgs; [
        # keep-sorted start
        bat
        file
        # keep-sorted end
      ];
      text = ''
        path="''${1-}"

        if [ -z "$path" ]; then
          exit 0
        fi

        mime_info=$(file --brief --mime --dereference -- "$path")

        if [ "''${mime_info##*charset=}" != "binary" ]; then
          bat -n --color=always -- "$path" || file --brief --dereference -- "$path"
        else
          file --brief --dereference -- "$path"
        fi
      '';
    };
  };
}
