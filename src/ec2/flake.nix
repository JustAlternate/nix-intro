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
      systemArm = "aarch64-linux"; # Matched from context [3]

      sharedNixosConfig = nixpkgs.lib.nixosSystem {
        system = systemArm;
        specialArgs = {
          inherit inputs;
        };
        modules = [ ./sac/default.nix ];
      };

      hostIpsFile = ./host_ips.json;

      generatedNodes =
        if builtins.pathExists hostIpsFile then
          let
            ipFileContent = builtins.readFile hostIpsFile;
            ipList = builtins.fromJSON ipFileContent;
            deployLibForSystem = deploy-rs.lib.${systemArm};
          in
          # Use nixpkgs.lib.listToAttrs to convert a list of attrsets to a single attrset.
          # Each item in the list produced by imap0 will be like:
          #   { name = "instance-0"; value = { hostname = "ip_addr"; profiles = { ... }; }; }
          # listToAttrs converts this into:
          #   { "instance-0" = { hostname = "ip_addr"; profiles = { ... }; }; ... }
          nixpkgs.lib.listToAttrs (
            # nixpkgs.lib.imap0 maps over a list providing (0-based index, element)
            nixpkgs.lib.imap0 (index: ip: {
              # Generate a unique name for each node, e.g., "instance-0", "instance-1"
              name = "instance-${toString index}";
              value = {
                hostname = ip; # The IP address from the list
                sshOpts = [
                  "-o"
                  "StrictHostKeyChecking=no"
                ];
                profiles = {
                  system = {
                    user = "root";
                    sshUser = "root";
                    path = deployLibForSystem.activate.nixos sharedNixosConfig;
                  };
                };
              };
            }) ipList
          )
        else
          builtins.trace
            "Warning: '${toString hostIpsFile}' not found. No dynamic nodes will be deployed from it."
            { };

    in
    {
      # The shared NixOS configuration is also exposed here, e.g., for building locally
      nixosConfigurations.defaultInstanceConfig = sharedNixosConfig;
      deploy.nodes = generatedNodes;

      checks = builtins.mapAttrs (_: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
