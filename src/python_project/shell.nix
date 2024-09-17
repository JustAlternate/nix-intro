with import <nixpkgs> { };

stdenv.mkDerivation {
  name = "python-environment";

  buildInputs = [
    pkgs.python311
    pkgs.python311Packages.flask
    pkgs.docker
    pkgs.docker-compose
  ];

  shellHook = ''
    export FLASK_APP="app.py"
    export FLASK_DEBUG=1

    echo "Welcome to my-python-app environment"

    # docker compose up -d
    # Ensure Docker services stop when shell exits
    # trap 'docker compose down' EXIT
  '';
}
