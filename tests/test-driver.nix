{ inputs, ... }:

{
  imports = [ inputs.nix-unit.modules.flake.default ];

  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    {
      nix-unit = {
        package = pkgs.nix-unit;
        inputs = lib.removeAttrs inputs [ "self" ];
      };
    };
}
