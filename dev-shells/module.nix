{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        inputsFrom = [
          # keep-sorted start block=yes
          config.pre-commit.devShell
          config.treefmt.build.devShell
          # keep-sorted end
        ];
        packages = [
          pkgs.nil
        ];
      };
    };
}
