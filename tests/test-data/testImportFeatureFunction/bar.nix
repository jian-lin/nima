{ thisFeature }:

{ lib, pkgs, ... }:

{
  options = {
    barElisp = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "(defvar bar 2)";
      description = "bar elisp";
    };
    barPkg = lib.mkOption {
      type = lib.types.package;
      example = lib.literalExpression "pkgs.hello";
      description = "bar pkg";
    };
  };
  config = {
    barElisp = "(defvar foo 1)";
    barPkg = pkgs.cowsay;
    features.${thisFeature} = { };
  };
}
