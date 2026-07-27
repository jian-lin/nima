{
  perSystem = { pkgs, ... }: {
    # We heavily depend on withPackages.  Add its test from Nixpkgs to our tests.
    checks = { inherit (pkgs.emacs.tests) withPackages; };
  };
}
