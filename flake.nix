{
  description = "Crystal's system deployments";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      nixosConfigurations.seafoam = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.home-manager.nixosModules.home-manager
          ./configuration.nix
        ];
        specialArgs = { inherit inputs; };
      };
      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        pkgs.nixfmt-tree
      );
    };
}
