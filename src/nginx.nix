{ pkgs ? import <nixpkgs> { } }:
let
  version = "1.20.2";
in
pkgs.mkShell {
  buildInputs = [
    (pkgs.nginx.overrideAttrs (oldAttrs: {
      inherit version;
      src = pkgs.fetchurl {
        url = "https://nginx.org/download/nginx-${version}.tar.gz";
        sha256 = "sha256-lYh2dXeCGQoWU+FNwm38e6Jj3jEOBMET4R6X0b70WkI=";
      };
    }))
  ];
}
