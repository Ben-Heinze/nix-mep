{
  description = "A simple NixOS flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager-stable.inputs.nixpkgs.follows = "stable";
    home-manager-stable.url = "github:nix-community/home-manager/release-25.11";
    home-manager-unstable.inputs.nixpkgs.follows = "unstable";
    home-manager-unstable.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    unstable,
    home-manager-stable,
    ...
  } @ inputs: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    unstablePkgs = import unstable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.ben = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./cfgs/configuration.nix
        home-manager-stable.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ben = import ./cfgs/home.nix;
        }
      ];

      specialArgs = {
        inherit inputs;
        inherit unstablePkgs;
      };
    };
    #
    # homeConfigurations.jordan = home-manager-stable.lib.homeManagerConfiguration {
    #   inherit pkgs;
    #   modules = [
    #     ./cfgs/home.nix
    #   ];
    # };

    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = [ ];
    };
  };
}
