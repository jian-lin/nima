{ inputs, self, ... }:

{
  flake.overlays.default =
    final: _prev:
    let
      mkNima' =
        {
          module ? { },
          featuresDir ? null,
          collect ? collectAllNixFiles,
        }:
        lib.evalModules {
          class = "nima";
          modules = [
            final.pkgsModule
            (lib.modules.importApply ./_nima.nix { inherit featuresDir collect; })
            module
          ];
        };
      collectAllNixFiles = dirPath: dirPath |> fs.fileFilter (file: file.hasExt "nix") |> fs.toList;
      fs = lib.fileset;
      inherit (final) lib;
    in
    {
      mkNima = lib.mirrorFunctionArgs mkNima' (args: (mkNima' args).config.finalPackage);
      inherit mkNima'; # useful for debug
    };

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = { };
        overlays = [ self.overlays.default ];
      };
    };
}
