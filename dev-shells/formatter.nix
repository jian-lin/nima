{ inputs, ... }:

{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { config, ... }:
    {
      treefmt = {
        flakeCheck = !(config.pre-commit.check.enable && config.pre-commit.settings.hooks.treefmt.enable);

        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          nixf-diagnose.enable = true;
        };

        programs.yamlfmt.enable = true;

        programs.keep-sorted.enable = true;
      };
    };
}
