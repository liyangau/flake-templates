# Nix flake templates

Here are the templates I often employ for my projects. They works perfectly with `nix develop` command and [nix-direnv](https://github.com/nix-community/nix-direnv). 

## Input URLs

I use shorthand for the input urls.

- `systems.url = "systems";` -> `github:nix-systems/default`
- `nixpkgs.url = "nixpkgs";` -> `github:NixOS/nixpkgs/nixpkgs-unstable`
- `nur.url = "nur";` -> `github:nix-community/NUR` 

Feel free to change the inputs if you want to use a different input. For example, you can change the input to below

```nix
  inputs = {
    systems.url = "github:nix-systems/x86_64-linux";
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
  };
```

## Systems

I'd rather not have to remember specific system names and be forced to include them in every single flake I use. The truth is, I never really want to specify which system my flake is being used on; I just want it to run on all systems. 

```nix
    allSystems = [
      "x86_64-linux" # 64-bit Intel/AMD Linux
      "aarch64-linux" # 64-bit ARM Linux
      "x86_64-darwin" # 64-bit Intel macOS
      "aarch64-darwin" # 64-bit ARM macOS
    ];
```

[flake-utils](https://github.com/numtide/flake-utils) is a popular solution to this problem. After reading [Why you don't need flake-utils](https://ayats.org/blog/no-flake-utils/), I've opted to use [nix-systems](https://github.com/nix-systems/nix-systems) instead.

## Templates

Currently I have 4 templates to cover my daily needs.

### default / shell

This template generates a flake that enables you to initiate the CLI exclusively for the project. For instance, if I solely require Terraform for my infrastructure projects, I can use this template to launch the `opentofu` CLI.

```bash
nix flake init -t github:liyangau/flake-templates
```

### nur

This template leverages packages accessible from [NUR](https://nur.nix-community.org/). I've uploaded several packages I use daily onto NUR. With this template, I can easily access the CLI on a per-project basis.

```bash
nix flake init -t github:liyangau/flake-templates#nur
```

### local

This template reads a local `default.nix` file, built the package and create shell environment with the package. It is useful when the package isn't accessible via nixpkgs or NUR. Typically, I use [nix-init](https://github.com/nix-community/nix-init) to generate the `default.nix` file automatically, which I subsequently integrate into my local project.

```bash
nix flake init -t github:liyangau/flake-templates#local
```

### python

This template gives me a shell with Python 3.12 along with certain libraries to my needs.

```bash
nix flake init -t github:liyangau/flake-templates#python
```

## unfree App

Sometimes, you might encounter errors similar to the following when attempting to use the flake. This typically occurs due to one of the packages being non-free, such as terraform.

```bash
       a) To temporarily allow unfree packages, you can use an environment variable
          for a single invocation of the nix tools.

            $ export NIXPKGS_ALLOW_UNFREE=1

          Note: When using `nix shell`, `nix build`, `nix develop`, etc with a flake,
                then pass `--impure` in order to allow use of environment variables.

       b) For `nixos-rebuild` you can set
         { nixpkgs.config.allowUnfree = true; }
       in configuration.nix to override this.

       Alternatively you can configure a predicate to allow specific packages:
         { nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
             "terraform"
           ];
         }

       c) For `nix-env`, `nix-build`, `nix-shell` or any other Nix command you can add
         { allowUnfree = true; }
       to ~/.config/nixpkgs/config.nix.
```

To solve the issue, you need to add `config.allowUnfree = true;` to `forEachSystem` as below.

```nix
    let
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs (import systems) (
          system:
          f {
            pkgs = import nixpkgs {
              config.allowUnfree = true;
              inherit system;
            };
          }
        );
    in
```