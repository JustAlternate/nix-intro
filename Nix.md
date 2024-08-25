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

## **Atomicity**

```
/nix/store/b6gvzjyb2pg0kjfwrjmg1vfhh54ad73z-firefox-33.1/
```




