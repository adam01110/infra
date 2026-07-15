# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    authentik-nix = {
      url = "github:nix-community/authentik-nix";
      inputs.flake-parts.follows = "flake-parts";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    disko = {
      url = "github:nix-community/disko?ref=latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hylix = {
      url = "git+https://tangled.org/adam0.dev/hylix";
      inputs = {
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.55.4";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    import-tree.url = "github:vic/import-tree";
    lanzaboote = {
      url = "github:nix-community/lanzaboote?ref=v1.1.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "tuigreet/rust-overlay";
      };
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel?ref=release";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-userstyles = {
      url = "git+https://tangled.org/adam0.dev/nix-userstyles";
      inputs = {
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.flake-parts.follows = "flake-parts";
    };
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    nixpkgs-crowdsec.url = "github:TornaxO7/nixpkgs/saltsprint";
    nixpkgs-crowdsec-blocklist-import.url = "github:gaelj/nixpkgs/init-crowdsec-blocklist-import";
    noctalia = {
      url = "github:noctalia-dev/noctalia?ref=legacy-v4";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        noctalia-qs.follows = "noctalia-qs";
      };
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nvf = {
      url = "github:adam01110/nvf?ref=personal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    overzicht = {
      url = "git+https://tangled.org/adam0.dev/overzicht";
      inputs = {
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        nur.follows = "nur";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tuigreet = {
      url = "github:notashelf/tuigreet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake?ref=beta";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };
}
