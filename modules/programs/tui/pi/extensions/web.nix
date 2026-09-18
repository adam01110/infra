{
  flake.modules.homeManager.pi = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe';

    # keep-sorted start
    chmod = getExe' pkgs.coreutils "chmod";
    cp = getExe' pkgs.coreutils "cp";
    jq = getExe' pkgs.jq "jq";
    mkdir = getExe' pkgs.coreutils "mkdir";
    mv = getExe' pkgs.coreutils "mv";
    # keep-sorted end

    jsonFormat = pkgs.formats.json {};

    # Search curation stays out of the browser: summaries come from the model
    # and no curator window opens on its own.
    curatorConfig = jsonFormat.generate "pi-web-search-curator.json" {
      autoOpenBrowser = false;
      workflow = "auto-summary";
    };
  in {
    # pi-suite's model-profile glue rewrites summaryModel in this file on model
    # switches, so it stays writable and activation only merges these keys.
    home.activation.writePiWebSearchConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      dir="$HOME/.config/pi"
      cfg="$dir/web-search.json"

      ${mkdir} -p "$dir"

      if [ -f "$cfg" ]; then
        ${jq} -s '.[0] * .[1]' "$cfg" ${curatorConfig} > "$cfg.tmp"
      else
        ${cp} ${curatorConfig} "$cfg.tmp"
      fi

      ${chmod} 600 "$cfg.tmp"
      ${mv} -f "$cfg.tmp" "$cfg"
    '';
  };
}
