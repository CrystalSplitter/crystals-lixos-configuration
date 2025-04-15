{
  description = "Crystal's system deployments";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, ... }:
  {
    nixosConfigurations.seafoam = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.home-manager.nixosModules.home-manager
      	./configuration.nix
      ];
      specialArgs = { inherit inputs; };
    };
  };
}
