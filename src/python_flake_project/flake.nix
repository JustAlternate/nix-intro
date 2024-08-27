{
  description = "A Python project with Nix Flakes";

  inputs = {

    pkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05";

    # We could also specify other inputs such as other flakes
    # for example a CI flakes which would add our linting, tests... to the project.

  };

  outputs = { self, pkgs }:
    let
      system = "aarch64-linux";
    in
    {
      # Define a development shell for the project (callable with nix develop)
      devShell = pkgs.legacyPackages.${system}.mkShell {
        buildInputs = with pkgs; [
          python311
          python311Packages.flask
          git
          docker
          docker-compose
        ];

        shellHook = ''
          export FLASK_DEBUG=1
          export FLASK_APP="app.py"

          docker compose up -d

          # Ensure Docker services stop when shell exits
          trap 'docker compose down' EXIT
        '';

      };

      # Define a package for the project (callable with nix build)
      packages.${system}.my-python-app = pkgs.legacyPackages.${system}.python311.withPackages
        (p: [
          p.flask
          p.requests
        ]);

      # Define an application (callable with nix run) 
      apps.default = {
        type = "app";
        program = "${self.packages.${system}.my-python-app}/bin/python main.py";
      };
    };
}
