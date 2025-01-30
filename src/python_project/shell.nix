with import <nixpkgs> { };

stdenv.mkDerivation {
  name = "python-environment";

  buildInputs = [
    pkgs.python311
    pkgs.python311Packages.flask
  ];

  shellHook = ''
    export FLASK_APP="app.py"
    echo "===================================="
    echo "Welcome to my-python-app environment"
    echo "usage: python3 app.py"
    echo "===================================="
  '';
}
