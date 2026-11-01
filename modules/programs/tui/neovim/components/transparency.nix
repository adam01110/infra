{
  flake.modules.homeManager.neovim = {
    # keep-sorted start
    config,
    inputs,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (inputs.nvf.lib.nvim.dag) entryAfter;
    inherit (lib) mkIf;
    inherit (lib.generators) toLua;

    # base16 paints these with base00, which hides terminal transparency.
    groups = [
      "EndOfBuffer"
      "FoldColumn"
      "LineNr"
      "Normal"
      "NormalNC"
      "SignColumn"
      "VertSplit"
    ];
  in {
    config = mkIf config.stylix.targets.nvf.transparentBackground {
      # nvf's base16 theme ignores theme.transparent, so strip the background here.
      programs.nvf.settings.vim.luaConfigRC.transparency = entryAfter ["theme"] ''
        local groups = ${toLua {} groups}

        local function clearBackgrounds()
          for _, group in ipairs(groups) do
            local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
            if hl.bg then
              hl.bg = nil
              vim.api.nvim_set_hl(0, group, hl)
            end
          end
        end

        clearBackgrounds()
        vim.api.nvim_create_autocmd("ColorScheme", { callback = clearBackgrounds })
      '';
    };
  };
}
