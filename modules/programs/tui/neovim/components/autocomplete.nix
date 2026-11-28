{
  flake.aspects.neovim.homeManager = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      concatStringsSep
      mapAttrsToList
      # keep-sorted start
      ;
    inherit (lib.generators) mkLuaInline;

    inherit (config.programs.nvf.settings.vim.ui) borderType;

    blinkGitTokenPath = config.sops.secrets.github_token.path;
    colors = config.lib.stylix.colors.withHashtag;

    # Match Telescope floats: editor background with a muted outline.
    floatBg = colors.base00;
    floatBorder = {
      # keep-sorted start
      bg = floatBg;
      fg = colors.base04;
      # keep-sorted end
    };

    # Docs get treesitter highlights without LSP semantic tokens, so base0F
    # punctuation and link labels would otherwise dominate them.
    docRemaps = {
      # keep-sorted start
      "@markup.link.label" = "BlinkCmpDocLink";
      "@markup.list" = "BlinkCmpDocPunctuation";
      "@punctuation.delimiter" = "BlinkCmpDocPunctuation";
      "@punctuation.special" = "BlinkCmpDocPunctuation";
      # keep-sorted end
    };

    mkWinhighlight = groups:
      concatStringsSep "," (mapAttrsToList (from: to: "${from}:${to}") (groups // docRemaps));
  in {
    sops.secrets.github_token = {};

    programs.nvf.settings.vim = {
      autopairs.nvim-autopairs.enable = true;
      snippets.luasnip.enable = true;

      lazy.plugins."dyninput.nvim" = {
        package = pkgs.dyninput-nvim;
        setupModule = "dyninput";
        lazy = false;
      };

      highlight = {
        # keep-sorted start block=yes newline_separated=yes
        BlinkCmpDoc.bg = floatBg;

        BlinkCmpDocBorder = floatBorder;

        BlinkCmpDocLink.fg = colors.base0D;

        BlinkCmpDocPunctuation.fg = colors.base04;

        BlinkCmpDocSeparator = {
          # keep-sorted start
          bg = floatBg;
          fg = colors.base03;
          # keep-sorted end
        };

        BlinkCmpMenu.bg = floatBg;

        BlinkCmpMenuBorder = floatBorder;

        BlinkCmpSignatureHelp.bg = floatBg;

        BlinkCmpSignatureHelpBorder = floatBorder;
        # keep-sorted end
      };

      autocomplete.blink-cmp = {
        enable = true;
        friendly-snippets.enable = true;

        sourcePlugins = {
          # keep-sorted start block=yes newline_separated=yes
          conventional_commits = {
            enable = true;
            module = "blink-cmp-conventional-commits";
            package = pkgs.vimPlugins.blink-cmp-conventional-commits;
          };

          git = {
            enable = true;
            module = "blink-cmp-git";
            package = pkgs.vimPlugins.blink-cmp-git;
          };

          npm = {
            enable = true;
            module = "blink-cmp-npm";
            package = pkgs.vimPlugins.blink-cmp-npm-nvim;
          };

          ripgrep.enable = true;

          words = {
            enable = true;
            module = "blink-cmp-words.dictionary";
            package = pkgs.vimPlugins.blink-cmp-words;
          };
          # keep-sorted end
        };

        setupOpts = {
          keymap.preset = "default";

          # keep-sorted start
          cmdline.completion.menu.auto_show = true;
          fuzzy.implementation = "prefer_rust_with_warning";
          # keep-sorted end

          completion = {
            # keep-sorted start
            ghost_text.enabled = true;
            menu.border = borderType;
            # keep-sorted end

            keyword.range = "full";

            documentation = {
              auto_show = true;

              window = {
                border = borderType;

                winhighlight = mkWinhighlight {
                  # keep-sorted start
                  EndOfBuffer = "BlinkCmpDoc";
                  FloatBorder = "BlinkCmpDocBorder";
                  Normal = "BlinkCmpDoc";
                  # keep-sorted end
                };
              };
            };
          };

          signature = {
            enabled = true;

            # keep-sorted start
            show_on_insert = true;
            show_on_keyword = true;
            window.border = borderType;
            # keep-sorted end

            window.winhighlight = mkWinhighlight {
              # keep-sorted start
              FloatBorder = "BlinkCmpSignatureHelpBorder";
              Normal = "BlinkCmpSignatureHelp";
              # keep-sorted end
            };
          };

          sources.providers = let
            commitSourceEnabled = mkLuaInline ''
              function()
                return vim.tbl_contains({ "gitcommit", "jjdescription" }, vim.bo.filetype)
              end
            '';

            githubToken = mkLuaInline ''
              function()
                return vim.fn.readfile("${blinkGitTokenPath}")[1]
              end
            '';
          in {
            conventional_commits.enabled = commitSourceEnabled;

            git = {
              enabled = commitSourceEnabled;
              opts = {
                git_centers.github = {
                  # keep-sorted start
                  issue.get_token = githubToken;
                  mention.get_token = githubToken;
                  pull_request.get_token = githubToken;
                  # keep-sorted end
                };

                kind_icons = let
                  lockIcon = "";
                in {
                  # keep-sorted start
                  lockedIssue = lockIcon;
                  lockedPR = lockIcon;
                  # keep-sorted end
                };
              };
            };

            npm.enabled = mkLuaInline ''
              function()
                return vim.fs.basename(vim.api.nvim_buf_get_name(0)) == "package.json"
              end
            '';

            ripgrep.score_offset = -5;

            words.enabled = mkLuaInline ''
              function()
                return vim.tbl_contains({ "gitcommit", "jjdescription", "markdown" }, vim.bo.filetype)
              end
            '';
          };

          term = {
            enabled = true;

            completion = {
              # keep-sorted start
              ghost_text.enabled = true;
              menu.auto_show = true;
              # keep-sorted end

              list.selection = {
                # keep-sorted start
                auto_insert = true;
                preselect = true;
                # keep-sorted end
              };
            };
          };
        };
      };
    };
  };
}
