{ config, lib, ... }:

{
  config = {
    features.foo = {
      elisp = config.barElisp;
      epkgs = _epkgs: lib.optional config.features.bar.enable config.barPkg;
    };
  };
}
