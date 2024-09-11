---
theme: default
paginate: true
marp: true
---

![bg left:40% 60%](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fnixos.org%2Flogo%2Fnixos-logo-only-hires.png&f=1&nofb=1&ipt=14fbf5665920aa31053241ed333ac843cb1d25810d4f392bf6621c01234e3947&ipo=images)

# **Introduction to Nix**

Nix, the declarative approach

https://nixos.org/

---

# **The Problem**

- You upgrade a package in your system and find that others packages are broken because a shared dependency got upgraded aswell...
- Now your system is broken and there is no undo button :/
- You want to migrate a system installation and configuration to another place but don't want to redo all the steps you did for installing it..
- You installed a lot of dependencies during an installation but don't want to bother cleaning it all manually.
- You have a team who build massive services that takes hours to setup for development.
- You want to embrace real reproducibility.

---
<style scoped>
section {
  font-size: 25px;
}
.gray {
  color: lightgray;
}
</style>

# **What can Nix offer**

- Reproducible development environments.
- <span class="gray">Easy installation of software over URLs.</span>
- Easy transfer of software environments between computers.
- Declarative and reproducible specification of Linux machines.
- <span class="gray">Reproducible integration testing using virtual machines.</span>
- Avoidance of version conflicts with already installed software.
- Installing software from source code.
- Transparent build caching using binary caches.
- <span class="gray">Strong support for software auditability.</span>
- <span class="gray">First-class cross compilation support.</span>
- <span class="gray"> Remote builds.</span>
- <span class="gray"> Remote deployments.</span>
- Atomic upgrades and rollbacks.

---

![bg 60%](./assets/what_is_nix.jpg)

---

# **Nix is a package manager**

- A purely functional package manager.
- Can be installed on any Linux systemd based system (Ubuntu, macOS, WSL2..)
- Has 100 000+ packages.
- Declarative.
- Atomic.
- Reproducible.

---

## **Nix easy installation**

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

Make it easier to write, share and deploy reproducible Nix expression.

Cache the produced evaluation for faster runtime

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

`flake.lock`
```lock
{
  "nodes": {
    "nixpkgs": {
      "locked": {
        "lastModified": 1724615852,
        "narHash": "sha256-CB8YqljFSCXwW51LKAZYIQNsKypppHfraotRSYXDU7Q=",
        "owner": "NixOS",
        "repo": "nixpkgs",
        "rev": "bb8bdb47b718645b2f198a6cf9dff98d967d0fd4",
        "type": "github"
      },
      "original": {
        "id": "nixpkgs",
        "ref": "nixpkgs-24.05-darwin",
        "type": "indirect"
      }
    },
    "root": {
      "inputs": {
        "nixpkgs": "nixpkgs"
      }
    }
  },
  "root": "root",
  "version": 7
}
```
---

## **Want unstable packages ? Yes sir !**
```Nix
{
  description = "NixOS configuration with two or more channels";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable }:
  ...
    pkgs.firefox
    pkgs.unstable.chromium
  ...
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
# Nix tools
<style scoped>
section {
  font-size: 25px;
}
.blue {
  color: blue;
}
</style>

- <span class="blue">yarn2nix</span>: Generate Nix expressions from a yarn.lock file
- <span class="blue">node2nix</span>: Generate Nix expression from a package.json.
- <span class="blue">poetry2nix</span>: Build Python packages directly from Poetry's poetry.lock. No conversion step needed.
- <span class="blue">compose2nix</span>: Generate a NixOS config from a Docker Compose project (only for NixOS)
- <span class="blue">composer2nix</span>: Generate Nix expressions to build composer packages.
- <span class="blue">sbtderivation</span>: mkDerivation for sbt, similar to buildGoModule.
- <span class="blue">nixos-infect</span>: Replace a running non-NixOS Linux host with NixOS.


---

# NixOS


---


# Nix or Ansible ?

![bg right:50% 50%](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fexternal-preview.redd.it%2Fp45HRVNvA8N7CE_YestAW2BWF_jqw8o8E8W09pz7mNo.jpg%3Fauto%3Dwebp%26s%3D0938ce5b6f4c9384b36eeaa7c104e6b3acb5aba3&f=1&nofb=1&ipt=7a4d693534a41e8be2914524e04e9223ccc62bd35a4eba28f7e0ba7cec79268a&ipo=images)

---

# Nix with kube

---


