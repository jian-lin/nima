{ lib, ... }:

{
  imports = [ ./bar.nix ];

  options = {
    fooList1 = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ ];
    };
    fooList2 = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ ];
    };
  };
}
