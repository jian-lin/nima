{
  perSystem =
    {
      lib,
      pkgs,
      ...
    }:
    {
      options.nima = {
        lib.runInProjectRootWhenPossible = lib.mkOption {
          type = lib.types.functionTo lib.types.package;
          readOnly = true;
          description = ''
            Wrap a package.
            Run its exe in the project root when possible.
            Commnad line arguments are all passed to its exe.
          '';
        };
      };

      config.nima = {
        lib.runInProjectRootWhenPossible =
          pkg:
          pkgs.writeShellApplication {
            name = "run-in-project-root-when-possible";
            # NOTE it is intended not to use nix-provided git
            # because whether external git exists is part of the `if` condition check
            # TODO run git only once
            text = ''
              if git rev-parse --show-toplevel >/dev/null; then
                pushd "$(git rev-parse --show-toplevel)" >/dev/null
              else
                pushd . >/dev/null
              fi

              ${lib.getExe pkg} "$@"

              popd >/dev/null
            '';
          };
      };
    };
}
