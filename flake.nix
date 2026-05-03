{
  description = "nima: Configure Emacs, Declaratively";

  inputs = {
    # keep-sorted start block=yes
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "";
        gitignore.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-unit = {
      url = "github:nix-community/nix-unit";
      inputs = {
        nix-github-actions.follows = "";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "";
      };
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        imports =
          let
            fs = lib.fileset;
            isNix = file: file.hasExt "nix";
            isSpecialNix =
              file:
              lib.elem file.name [
                "flake.nix"
                "default.nix"
              ];
            isIgnored = file: lib.hasPrefix "_" file.name;
            filter = fs.fileFilter (file: isNix file && !isSpecialNix file && !isIgnored file);
            remove = lib.flip fs.difference;
          in
          filter ./. |> remove ./tests/test-data |> remove ./examples/nima-modules |> fs.toList;
        systems = lib.systems.flakeExposed;
      }
    );
}
