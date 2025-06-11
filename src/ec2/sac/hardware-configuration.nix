{ modulesPath, ... }:
{
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
  ec2.efi = true;

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
      ];
    };
  };
}
