{
  description = "Simple Nixos config flake to deploy mutliple host";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    deploy-rs.url = "github:serokell/deploy-rs";
  };
  outputs =
    {
      self,
      nixpkgs,
      deploy-rs,
      ...
    }@inputs:
    let
      systemArm = "aarch64-linux";
    in
    {
      nixosConfigurations = {
        instance = nixpkgs.lib.nixosSystem {
          system = systemArm;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./sac/default.nix ];
        };
      };
      deploy.nodes.instance = {
        hostname = "13.36.169.173";
        profiles = {
          system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.instance;
          };
        };
      };
      checks = builtins.mapAttrs (_: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
