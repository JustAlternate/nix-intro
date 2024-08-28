---
theme: default
paginate: true
---

![bg left:40% 60%](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fnixos.org%2Flogo%2Fnixos-logo-only-hires.png&f=1&nofb=1&ipt=14fbf5665920aa31053241ed333ac843cb1d25810d4f392bf6621c01234e3947&ipo=images)

# **Introduction to Nix**

Nix, the declarative approach

https://nixos.org/

---

![bg 60%](./assets/what_is_nix.jpg)

---

# **Nix is a package manager**

- A purely functional package manager.
- Can be installed on any Linux systemd based system (Ubuntu, macOS, WSL2..)
- Has 100 000+ packages.
- Atomic.
- Reproducible.

---

## **Nix installation**

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Once installed, one can **temporarly** install a package using:  

```bash
nix-shell -p kubectl
```

---

![bg 75%](https://repology.org/graph/map_repo_size_fresh.svg)

---

## **Nix store**

```
/nix/store/b6gvzjyb2pg0kjfwrjmg1vfhh54ad73z-firefox-33.1/
```
Contains all the build products including binaries, libraries, configurations files... 
Permit the installation of multiple packages with different versions and configurations.
Are immutable, isolated and atomic

---

## **Declarative approach for development**
`my-python-app/app.py`
```python
#!/usr/bin/env python

from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return {
        "message": "Hello, Nix!"
    }

def run():
    app.run(host="0.0.0.0", port=5000)

if __name__ == "__main__":
    run()
```
---

## **Declarative approach for development**
`my-python-app/shell.nix`
```Nix
with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "python-environment";

  buildInputs = [ 
    pkgs.python311 
    pkgs.python311Packages.flask
    pkgs.docker
    pkgs.docker-compose
  ];

  shellHook = ''
    export FLASK_APP="app.py"

    echo "Welcome to my-python-app environment"

    docker-compose up -d
    trap 'docker-compose down' EXIT
    
  '';
}
```

---

## **Flakes**

Experimental feature of Nix (but is vastly used by the majority of the community)

Allow for a standardized project structure.

Make it easier to write reproducible nix expression.

Pin versions of dependencies in a lock file.

![bg right:40% 60%](https://i.redd.it/m1nul7hzvcca1.png)

---

## **Flake example for making a reproducible dev environment**
`flake.nix`
```Nix
{
  description = "A Python project with Nix Flakes";
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-24.05-darwin";
  };
  outputs = { nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in
    {
      # Define a development shell for the project (callable with nix develop)
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs;
          [
            # Packages needed to dev in the project
            python311
            ...
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
          echo "Start the postgres local db"
          docker compose up -d
          trap 'docker compose down' EXIT

          echo "Configure pre-commit to reduce circle-ci costs"
          pre-commit install --hook-type pre-commit
        '';
      };
    };
}
```
---

# **Docker or Nix ?**

Docker is repeatable, but not reproducible because it relies on sources that change over time (such as apt repositories)

One docker build can have different output depending when it is done.

Because of:
```Dockerfile
FROM debian:stable
RUN apt-get update
RUN apt-get install nginx
```
---

Nix on the other hand is reproducible because it can pins down dependencies versions using our flake.lock

Or by overriding a package version:

```Nix
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
```
---
## **Using Docker within Nix**
```Dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY . .

RUN pip install flask

EXPOSE 5000

ENV FLASK_APP=app.py

CMD ["python", "app.py"]
```
---

## **Using Docker within Nix**

`pkgs.dockerTools` is a set of functions for creating and manipulating Docker images (note that Docker is not used behind the hood to perform these functions)

```Nix
{ pkgs ? import <nixpkgs> { } }:
pkgs.dockerTools.buildLayeredImage {
  name = "flask-app";
  config = {
    Cmd = [
      (pkgs.lib.getExe (pkgs.python3.withPackages (ps: with ps; [ flask ])))
      ./app.py
    ];
    ExposedPorts = { "5000/tcp" = { }; };
  };
}
```

```
nix-build DockerInNix.nix
docker run < result
```

---

## **Using Nix within Docker**
---

# Nix or Ansible ?

![bg right:50% 50%](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fexternal-preview.redd.it%2Fp45HRVNvA8N7CE_YestAW2BWF_jqw8o8E8W09pz7mNo.jpg%3Fauto%3Dwebp%26s%3D0938ce5b6f4c9384b36eeaa7c104e6b3acb5aba3&f=1&nofb=1&ipt=7a4d693534a41e8be2914524e04e9223ccc62bd35a4eba28f7e0ba7cec79268a&ipo=images)

---


