{self, ...}: {
  flake.modules.homeManager.opencode = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) attrValues;
    inherit
      (lib)
      # keep-sorted start
      concatStringsSep
      escapeShellArg
      getExe
      getExe'
      makeBinPath
      mapAttrsToList
      # keep-sorted end
      ;
    inherit (config.lib.file) mkOutOfStoreSymlink;
    inherit
      (pkgs)
      # keep-sorted start
      makeWrapper
      symlinkJoin
      # keep-sorted end
      ;

    inherit
      (config.programs.opencode)
      # keep-sorted start
      env
      mcpServers
      # keep-sorted end
      ;

    home = config.home.homeDirectory;
    wrapEnvArgs = concatStringsSep " \\" (
      mapAttrsToList
      (name: value: "--set ${escapeShellArg name} ${escapeShellArg (toString value)}")
      env
    );
  in {
    imports = with self.modules.homeManager; [
      # keep-sorted start
      nur
      shellAbbreviations
      xdgTerminal
      # keep-sorted end
    ];

    # keep-sorted start block=yes newline_separated=yes
    home.shellAbbreviations.oc = "opencode";

    programs.opencode = {
      enable = true;

      # Wrap opencode with mcp's, and other dependencies.
      package = symlinkJoin {
        name = "opencode-wrapped";
        paths = [pkgs.nur.repos.adam0.opencode];
        nativeBuildInputs = [makeWrapper];

        # Set feature flags and prepend runtime tools before launching opencode.
        postBuild = ''
          wrapProgram $out/bin/opencode \
            ${wrapEnvArgs} \
            --prefix PATH : ${makeBinPath ((with pkgs; [
              # keep-sorted start
              libnotify
              nur.repos.adam0.modular-mcp
              wl-clipboard
              # keep-sorted end
            ])
            ++ attrValues mcpServers)}
        '';
      };

      # Set agent rules.
      context = ./instructions.md;
    };

    xdg = {
      # Point opencode at the shared agent skills directory.
      configFile."opencode/skills".source = mkOutOfStoreSymlink "${home}/.agents/skills";

      # Create desktop entry to allow launching via launcher.
      desktopEntries.opencode = {
        name = "Opencode";
        genericName = "AI Coding Assistant";

        exec = let
          # keep-sorted start
          opencode = getExe' config.programs.opencode.package "opencode";
          terminalCommand = getExe config.xdg.terminal-exec.package;
          # keep-sorted end
        in "${terminalCommand} --title=Opencode ${opencode}";

        categories = [
          # keep-sorted start
          "ConsoleOnly"
          "Development"
          # keep-sorted end
        ];
      };
    };
    # keep-sorted end
  };
}
