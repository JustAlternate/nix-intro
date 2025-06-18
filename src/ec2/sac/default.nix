{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  services = {
    immich = {
      enable = true;
      port = 80;
      openFirewall = true;
      settings = {
        passwordLogin.enable = false;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    cmatrix
  ];
}
