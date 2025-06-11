{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./glance.nix
  ];

  environment.systemPackages = with pkgs; [
    vim
    cmatrix
  ];
}
