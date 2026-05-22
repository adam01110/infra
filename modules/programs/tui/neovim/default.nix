{
  # keep-sorted start
  inputs,
  self,
  # keep-sorted end
  ...
}: {
  flake-file.inputs = {
    nvf = {
      url = "github:adam01110/nvf?ref=personal";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  flake.modules.nixos.neovim = {
    nix.settings = let
      cache = "https://nvf.cachix.org/";
    in {
      substituters = [cache];
      trusted-substituters = [cache];
      trusted-public-keys = ["nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="];
    };
  };

  flake.modules.homeManager.neovim = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      concatStringsSep
      mkOption
      types
      # keep-sorted end
      ;

    cfg = config.nvf;
  in {
    imports =
      [inputs.nvf.homeManagerModules.default]
      ++ (with self.modules.homeManager; [
        # keep-sorted start
        git
        stylixBase
        # keep-sorted end
      ]);

    options.nvf = {
      # keep-sorted start block=yes newline_separated=yes
      borderType = mkOption {
        type = types.str;
        default = "single";
        description = "Border style for Neovim floating UI.";
      };

      luaConfigPreSnippets = mkOption {
        type = types.listOf types.lines;
        default = [];
        description = "Lua snippets concatenated into nvf's luaConfigPre.";
      };
      # keep-sorted end
    };

    config = {
      programs.nvf = {
        enable = true;
        enableManpages = true;

        settings.vim = {
          enableLuaLoader = true;
          luaConfigPre = concatStringsSep "\n" cfg.luaConfigPreSnippets;

          # keep-sorted start
          statusline.lualine.enable = true;
          utility.snacks-nvim.enable = true;
          # keep-sorted end
        };
      };

      # Export editor vars for cli tools.
      home.sessionVariables = let
        editor = "nvim";
      in {
        # keep-sorted start
        EDITOR = editor;
        VISUAL = editor;
        # keep-sorted end
      };

      stylix.targets.nvf.transparentBackground = true;
    };
  };
}
