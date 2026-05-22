{ inputs, ... }:

{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { config, ... }:
    {
      treefmt = {
        flakeCheck = !(config.pre-commit.check.enable && config.pre-commit.settings.hooks.treefmt.enable);

        programs = {
          deadnix = {
            enable = true;
            priority = 1;
          };
          nixf-diagnose = {
            enable = true;
            priority = 2;
          };
          nixfmt = {
            enable = true;
            priority = 3;
          };
        };

        programs.yamlfmt.enable = true;

        programs.keep-sorted.enable = true;
      };
    };
}
