{ pkgs ? import <nixpkgs> {} }:

let
  scalaVersion = "2.13.8";
  sbtVersion = "1.6.2";
in
pkgs.mkShell {
  buildInputs = [
    pkgs.scala_2_13
    (pkgs.sbt.overrideAttrs (oldAttrs: rec {
      version = sbtVersion;
      src = pkgs.fetchurl {
        url = "https://github.com/sbt/sbt/releases/download/v${version}/sbt-${version}.tgz";
        sha256 = "sha256-Y3Y3tsTm+gSrYs02QGHjKxJICwkAHNIzA99is2+t1EA=";
      };
    }))
  ];

  shellHook = ''
    echo "Starting sbt..."
    sbt
  '';
}
