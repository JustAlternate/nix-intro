{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  name = "golang-environment";

  buildInputs = [
    pkgs.go
  ];

  shellHook = ''
    export GOPATH=$PWD/go
    mkdir -p $GOPATH/src $GOPATH/bin $GOPATH/pkg
    export PATH=$PATH:$GOPATH/bin
    go get -u github.com/gorilla/mux
  '';
}
