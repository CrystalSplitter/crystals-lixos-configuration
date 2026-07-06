{
  description = "Crystal's system deployments";
  inputs = {
    nixpkgs.url = "github:/NixOS/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:/NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fluentflame-reader.url = "github:FluentFlame/fluentflame-reader/master?dir=nix";
  };
  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (
        mySystem:
        import nixpkgs {
          system = mySystem;
        }
      );
    in
    {
      nixosConfigurations.seafoam = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.home-manager.nixosModules.home-manager
          ./configuration.nix
          {
            nixpkgs.overlays = [
              (
                _final: prev:
                let
                  prevSystem = prev.stdenv.hostPlatform.system;
                in
                {
                  fluentflame-reader = inputs.fluentflame-reader.packages.${prevSystem}.default;
                }
              )
              (
                final: _prev:
                {
                  # Patch for https://github.com/NixOS/nixpkgs/issues/536623
                  pnpm_10_29_2 = final.pnpm_10;
                }
              )
              #(
              #  # Downgrade Krita to stable.
              #  final: prev:
              #  let
              #    prevSystem = prev.stdenv.hostPlatform.system;
              #  in
              #  {
              #    krita = inputs.nixpkgs-stable.legacyPackages.${prevSystem}.krita;
              #  }
              #)
            ];
          }
        ];
        specialArgs = { inherit inputs; };
      };
      formatter = forAllSystems (
        mySystem:
        let
          pkgs = nixpkgsFor.${mySystem};
        in
        pkgs.nixfmt-tree
      );
    };
}
