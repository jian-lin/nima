{ thisFeature }:

{ config, lib, ... }:

{
  config = {
    features.${thisFeature} = {
      elisp = config.barElisp;
      epkgs = _epkgs: lib.optional config.features.bar.enable config.barPkg;
    };
  };
}
