Migration Plan
flake-file:

- flake.nix should become generated output, not hand-maintained.
- Source-of-truth lives under modules/.
- Use inputs.flake-file.flakeModules.dendritic for the dendritic setup.
- Declare inputs through flake-file.inputs, preferably close to the module that needs them.
- Generate with nix run .#write-flake after bootstrapping, or bootstrap with write-flake --arg modules ./modules.

flake-parts:

- Each file under modules/ should be a flake-parts module.
- Use perSystem for packages, dev shells, formatter, checks.
- Use flake.nixosConfigurations for hosts.
- Use flake.modules.nixos.* and flake.modules.homeManager.* for reusable feature/aspect modules.
- Use withSystem when host construction needs per-system packages or inputs.

import-tree:

- Keep it incidental. It is mainly the recursive loader behind the dendritic pattern.
- Paths prefixed with _ are ignored by import-tree.

Target Layout
Based on the current ~/Infra template and your existing /home/adam0/Nixos structure:
~/Infra/
  assets/
    face.png
    logo.png
  modules/
    nix/
      dendritic.nix
      inputs.nix
      systems.nix
      treefmt.nix
      devshell.nix
    hosts/
      desktop.nix
      laptop.nix
      vm.nix
    profiles/
      base.nix
      desktop.nix
      laptop.nix
      vm.nix
    nixos/
      boot.nix
      disk.nix
      locale.nix
      nix.nix
      sops.nix
      user.nix
      tweaks.nix
    nixos/services/
      ananicy.nix
      avahi.nix
      bluetooth.nix
      geoclue.nix
      gnome-keyring.nix
      gvfs.nix
      locate.nix
      logind.nix
      network.nix
      other.nix
      pipewire.nix
      podman.nix
      printing.nix
      scx.nix
      ssh.nix
      timesyncd.nix
      timezone.nix
      tlp.nix
      zram.nix
    nixos/desktop/
      hyprland.nix
      stylix.nix
      tablet.nix
      tuigreet.nix
      xdg-portal.nix
    nixos/gui/
      lsfg.nix
      other.nix
      steam.nix
      virt-manager.nix
    nixos/cli/
      man.nix
      nh.nix
      other.nix
      sudo-rs.nix
    home/
      base.nix
      desktop.nix
      laptop.nix
      vm.nix
    packages/
      default.nix
      scripts.nix
      lutris.nix
      nocheatsheet-nvim.nix
      telescope-all-recent-nvim.nix
      zaread.nix
    lib/
      default.nix
  keys/
  secrets/
  vars.nix
  .sops.yaml
  .envrc
  README.md
  THIRD_PARTY_NOTICES.md
Phase 1: Bootstrap Flake-File

1. Keep ~/Infra/flake.nix temporary until generation works.
2. Move optional inputs closer to usage later:
   - Hyprland-related inputs near Hyprland modules.
   - Stylix near Stylix module.
   - Nixcord/spicetify/zen/noctalia near home modules.
   - Kernel/boot inputs near boot modules.
Phase 2: Move Flake-Parts Infrastructure
3. Move existing /home/adam0/Nixos/flake/treefmt.nix to modules/nix/treefmt.nix.
4. Move existing /home/adam0/Nixos/flake/devshell.nix to modules/nix/devshell.nix.
5. Convert package wiring from /home/adam0/Nixos/pkgs/default.nix into modules/packages/default.nix as perSystem.packages.
6. Keep systems = import inputs.systems in a small modules/nix/systems.nix.
Phase 3: Convert NixOS Modules Into Dendritic Aspects
7. Current modules/system/*.nix files should stop being imported as one big tree.
8. Each should become a named exported module:
   - flake.modules.nixos.base
   - flake.modules.nixos.nix
   - flake.modules.nixos.sops
   - flake.modules.nixos.hyprland
   - flake.modules.nixos.pipewire
   - etc.
9. Preserve most module bodies as-is. The migration is mostly wrapping each module under flake.modules.nixos.<name> = { ... };.
10. Avoid large rewrites while migrating. First goal is equivalent behavior.
Phase 4: Split Host Composition
11. Replace current mkHost style from /home/adam0/Nixos/flake/nixos.nix with one host file per host:
    - modules/hosts/desktop.nix
    - modules/hosts/laptop.nix
    - modules/hosts/vm.nix
12. Each host file defines flake.nixosConfigurations.<host>.
13. Each host composes modules from inputs.self.modules.nixos.
14. Host-specific hardware stays host-local.
15. Host-specific home-manager overrides move to modules/home/<host>.nix or inline host composition.
Example composition shape:
{

    inputs,
    withSystem,
    ...
}: {

  flake.nixosConfigurations.laptop = withSystem "x86_64-linux" ({config, ...}:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = with inputs.self.modules.nixos; [
        base
        nix
        sops
        disk
        user
        hyprland
        pipewire
        bluetooth
        tlp
        laptop
      ];
    });
}
Phase 5: Home-Manager Dendritic Modules

18. Convert home-manager settings into flake.modules.homeManager.*.
19. Keep user identity defaults in one user module.
20. Move host-specific home settings from:
    - modules/hosts/laptop/home.nix
    - modules/hosts/vm/home.nix
    - modules/hosts/desktop/home.nix
21. Compose home-manager modules from the NixOS host module through home-manager.users.${username}.imports.
Phase 6: Input Locality Cleanup
After equivalent behavior works:
22. Move hyprland, hyprland-plugins, hyprsplit, and tuigreet input declarations into desktop/Hyprland-related modules.
23. Move stylix into modules/nixos/desktop/stylix.nix.
24. Move nix-index-database into shell/CLI module.
25. Move nix-flatpak, millennium, spicetify-nix, nixcord, zen-browser, noctalia, oxicord, etc. into the feature module that consumes each input.
26. Keep only foundational inputs in modules/nix/inputs.nix.
Phase 7: Generated Flake Workflow
27. Treat flake.nix as generated.
28. Generate it from modules/ using flake-file.
29. Verify generated flake.nix contains only inputs and generated outputs glue.
30. Add a check or workflow expectation that generated flake.nix is up to date.
Commands for execution phase:
nix run .#write-flake
nix flake check
Bootstrap fallback if .#write-flake is not available yet:
nix-shell <https://github.com/vic/flake-file/archive/refs/heads/main.zip> \
  -A flake-file.sh --run write-flake --arg modules ./modules
Migration Order
31. Establish flake-file dendritic bootstrap in ~/Infra/modules/nix.
32. Port systems, treefmt, and devshell.
33. Port package outputs.
34. Export current NixOS modules as flake.modules.nixos.*.
35. Build laptop, desktop, and vm host compositions.
36. Port home-manager modules.
37. Move input declarations close to usage.
38. Generate flake.nix.
39. Run nix flake check.
40. Compare host builds against the old repo with nixos-rebuild build --flake .#<host>.
