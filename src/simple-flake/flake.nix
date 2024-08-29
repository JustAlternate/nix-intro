{
  description = "A Python project with Nix Flakes";
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-24.05-darwin";
  };
  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    { };
}
