{ pkgs ? import <nixpkgs> { } }:
pkgs.dockerTools.buildImage {
  name = "flask-app";
  config = {
    Cmd = [
      (pkgs.lib.getExe (pkgs.pkgsCross.musl64.python3.withPackages (ps: with ps; [ flask ])))
      ./app.py
    ];
    ExposedPorts = { "5000/tcp" = { }; };
  };
}
