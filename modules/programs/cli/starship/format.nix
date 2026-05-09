{
  flake.modules.homeManager.starship = {lib, ...}: let
    inherit (lib) concatStrings;
  in {
    # Layout and coloring for the full starship prompt.
    programs.starship.settings.format = concatStrings [
      "[ ](bg:base01)"
      "$hostname"
      "[/](fg:base05 bg:base01)"
      "$username"
      "[ ](bg:base01)"

      "[ ](#00000000)"
      "[ ](bg:base01)"
      "$os"
      "[ ](bg:base01)"
      "$shell"
      "[ ](bg:base01)"

      "$nix_shell"

      "$container"
      "$docker_context"

      "$directory"
      "$direnv"
      "$sudo"
      "$jobs"

      "$fossil_branch"
      "[ ](#00000000)"
      "[ ](bg:base01)"
      "$git_branch"
      "[ ](bg:base01)"
      "$git_commit"
      "$git_state"
      "$git_status"
      "[ ](bg:base01)"

      "$package"

      "$bun"
      "$deno"
      "$nodejs"

      "$cmake"
      "$gradle"
      "$meson"

      "$c"
      "$cpp"
      "$dart"
      "$dotnet"
      "$golang"
      "$haskell"
      "$haxe"
      "$java"
      "$kotlin"
      "$lua"
      "$perl"
      "$php"
      "$python"
      "$ruby"
      "$rust"
      "$swift"
      "$zig"

      "$cmd_duration"

      "$line_break"
      "$character"
    ];
  };
}
