{
  description = "Crystal's system deployments";
  inputs = {
    nixpkgs.url = "github:/NixOS/nixpkgs/nixos-unstable";
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
                final: prev:
                let
                  prevSystem = prev.stdenv.hostPlatform.system;
                in
                {
                  fluentflame-reader = inputs.fluentflame-reader.packages.${prevSystem}.default;
                }
              )
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
