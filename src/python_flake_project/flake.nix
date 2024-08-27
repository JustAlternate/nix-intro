{
  description = "A Python project with Nix Flakes";
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-24.05-darwin";
    # We could also specify other inputs such as other flakes
    # for example a CI flakes which would add our linting, tests... to the project.
  };
  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Define a development shell for the project (callable with nix develop)
      devShells.${system}.default = pkgs.mkShell {
        # Package that we want to use in our development environment
        buildInputs = with pkgs;
          [
            # Packages needed to dev in the project
            python311
            python311Packages.flask
            docker
            docker-compose
            # tools
            jq
            # Linter / formatters...
            black
            ruff
            # git shenanigans
            git
            pre-commit
          ];

        shellHook = ''
          echo "Setup env params"
          export FLASK_APP="app.py"

          echo "Start the postgres local db"
          docker compose up -d
          trap 'docker compose down' EXIT

          echo "Configure pre-commit to reduce circle-ci costs"
          pre-commit install --hook-type pre-commit
        '';
      };
    };
}
