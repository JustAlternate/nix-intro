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
nix-shell -p cmatrix
```

---

![bg 75%](/home/justalternate/screenshots/20240825-18:14:02.png)

---

## **Nix store**

```
/nix/store/b6gvzjyb2pg0kjfwrjmg1vfhh54ad73z-firefox-33.1/
```
Contains all the build products including binaries, libraries, configurations files... 
Permit the installation of multiple package version and configuration.
Are immutable, isolated and atomic

---

# **Declarative approach**
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

# **Declarative approach**
`my-python-app/shell.nix`
```Nix
with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "python-environment";

  buildInputs = [ pkgs.python311 pkgs.python311Packages.flask ];

  shellHook = ''
    export FLASK_DEBUG=1
    export FLASK_APP="app.py"
  '';
}
```

---
# **Using Nix within Docker**
---


