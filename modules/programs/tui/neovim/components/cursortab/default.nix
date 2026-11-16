{
  flake.aspects.neovim.homeManager = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) readFile;
    inherit (lib.generators) mkLuaInline toLua;
    inherit (lib.lists) concatMap;
    inherit (lib.modules) mkForce;
    inherit (lib.self) blendHex;

    colors = config.lib.stylix.colors.withHashtag;

    # Directories whose contents never leave the machine.
    secretDirs = [
      # keep-sorted start
      ".aws"
      ".config/gh"
      ".docker"
      ".git"
      ".gnupg"
      ".kube"
      ".password-store"
      ".ssh"
      "agenix"
      "secrets"
      "sops"
      "wireguard"
      # keep-sorted end
    ];

    # Gitignore-style globs: no slash matches the basename, a slash matches the path.
    ignorePaths =
      [
        # keep-sorted start
        "*-lock.json"
        "*.age"
        "*.asc"
        "*.csv"
        "*.gpg"
        "*.gz"
        "*.jks"
        "*.kdbx"
        "*.key"
        "*.keystore"
        "*.lock"
        "*.log"
        "*.map"
        "*.min.css"
        "*.min.js"
        "*.ovpn"
        "*.p12"
        "*.parquet"
        "*.pem"
        "*.pfx"
        "*.png"
        "*.secret"
        "*.sops.*"
        "*.sum"
        "*.tar"
        "*.tfstate"
        "*.tfstate.*"
        "*.tfvars"
        "*.tfvars.json"
        "*.tsv"
        "*.zip"
        "*_history"
        ".credentials.json"
        ".env"
        ".env.*"
        ".envrc"
        ".git-credentials"
        ".htpasswd"
        ".netrc"
        ".npmrc"
        ".pgpass"
        ".pypirc"
        ".vault-token"
        "/dev/shm/**"
        "credentials"
        "credentials.json"
        "id_dsa*"
        "id_ecdsa*"
        "id_ed25519*"
        "id_rsa*"
        "kubeconfig*"
        "nix.conf"
        "rclone.conf"
        "secret.*"
        "secrets.*"
        # keep-sorted end
      ]
      # Cursortab matches relative to cwd inside it and absolute outside it.
      ++ concatMap (dir: ["${dir}/**" "**/${dir}/**"]) secretDirs;
  in {
    programs.nvf.settings.vim = {
      # Shared policy for every Copilot-bound document, loaded before LSP setup.
      luaConfigPreSnippets = [
        ''
          package.preload["copilot_guard"] = function()
            local factory = (function()
              ${readFile ./copilot-guard.lua}
            end)()
            return factory(${toLua {} ignorePaths})
          end
        ''
      ];

      highlight = {
        # keep-sorted start block=yes newline_separated=yes
        CursorTabAddition = {
          bg = blendHex 15 colors.base00 colors.base0B;
          fg = colors.base0B;
        };

        CursorTabCompletion.fg = colors.base04;

        CursorTabDeletion = {
          bg = blendHex 15 colors.base00 colors.base08;
          fg = colors.base08;
        };

        CursorTabJumpSymbol.fg = colors.base03;

        CursorTabJumpText = {
          bg = colors.base01;
          fg = colors.base04;
        };

        CursorTabModification = {
          bg = blendHex 15 colors.base00 colors.base0A;
          fg = colors.base0A;
        };
        # keep-sorted end
      };

      assistant.cursortab = {
        enable = true;

        setupOpts = {
          provider.type = "copilot";
          ui.jump.text = " Alt-y ";

          blink = {
            # keep-sorted start
            enabled = true;
            ghost_text = false;
            # keep-sorted end
          };

          behavior = {
            ignore_gitignored = false;
            ignore_paths = ignorePaths;
          };

          keymaps = {
            # keep-sorted start
            accept = "<M-y>";
            partial_accept = "<M-Y>";
            trigger = "<M-p>";
            # keep-sorted end
          };
        };
      };

      # Copilot LSP has no filetype list and would attach to every buffer.
      lsp.servers.copilot_ls = {
        root_dir = mkLuaInline ''
          function(bufnr, on_dir)
            require("copilot_guard").root_dir(bufnr, on_dir)
          end
        '';

        # Attach checks miss renames and cursortab's forced attach, so every message is filtered.
        on_init = mkForce (mkLuaInline ''
          function(client)
            require("copilot_guard").wrap(client)
          end
        '');
      };

      keymaps = [
        {
          key = "<leader>tc";
          mode = "n";
          action = "<cmd>CursortabToggle<cr>";
          desc = "Toggle cursortab";
        }
      ];
    };
  };
}
