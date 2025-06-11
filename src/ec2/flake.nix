{
  description = "Simple Nixos config flake to deploy mutliple host";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      systemArm = "aarch64-linux";
    in
    {
      nixosConfigurations = {
        instance1 = nixpkgs.lib.nixosSystem {
          system = systemArm;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./sac/default.nix ];
        };

        instance2 = nixpkgs.lib.nixosSystem {
          system = systemArm;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./sac/default.nix ];
        };
      };
    };
}
