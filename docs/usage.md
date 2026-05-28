# Usage

`nima` can be used in many ways.
However, the core steps are the same:

1. apply `nima` overlay to your Nixpkgs
1. use `mkNima` function
   to create a configured Emacs
1. use the configured Emacs
   in your Nix configuration

Here is an annotated example invocation of `mkNima`:

```nix
pkgs.mkNima {
  module = { pkgs, ... }: {
    package = pkgs.emacs-pgtk;
    # pedantic = true; # uncomment this if you want a warning-free elisp configuration
  };
  featuresDir = ./features;
}
```

See [README](/README.md#getting-started)
for full documentation of `mkNima`.

See [README](/README.md#examples)
for what files in `featuresDir` look like.

## Standalone

With the following `flake.nix`,
you can run the configured Emacs using `nix run`
on any systems with Nix installed.

This way of using `nima`
gives you
the fastest iteration speed
when changing your Emacs configuration.

> [!TIP]
> You can also use this configured Emacs
> in your NixOS or Home Manager configuration.

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nima.url = "github:jian-lin/nima";
  };
  outputs =
    { nixpkgs, nima, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nima.overlays.default ]; # apply nima overlay
        config = { };
      };
    in
    {
      packages.x86_64-linux.default = pkgs.mkNima {
        # see an annotated example invocation above
      };
    };
}
```

## NixOS

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nima.url = "github:jian-lin/nima";
  };
  outputs =
    { nixpkgs, nima, ... }:
    {
      nixosConfigurations = {
        hostname1 = nixpkgs.lib.nixosSystem {
          modules = [
            {
              nixpkgs.overlays = [ nima.overlays.default ]; # apply nima overlay
              environment.systemPackages = [
                (pkgs.mkNima {
                  # see an annotated example invocation above
                })
              ];
            }
            # other NixOS configuration
          ];
        };
        hostname2 = nixpkgs.lib.nixosSystem {
          modules = [
            {
              nixpkgs.overlays = [ nima.overlays.default ]; # apply nima overlay
              services.emacs = {
                enable = true;
                package = pkgs.mkNima {
                  # see an annotated example invocation above
                };
                defaultEditor = true;
              };
            }
            # other NixOS configuration
          ];
        };
      };
    };
}
```

## Home Manager

Since there are many ways to use Home Manager,
we skip how to apply `nima` overlay
and just show an example Home Manager module.

```nix
# nima-home-manager-module.nix
{ pkgs, ... }:

{
  services.emacs = {
    enable = true;
    package = pkgs.mkNima {
      # see an annotated example invocation above
    };
    client.enable = true;
    defaultEditor = true;
    startWithUserSession = true;
  };
}
```
