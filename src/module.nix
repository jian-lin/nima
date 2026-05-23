{ inputs, self, ... }:

{
  flake.overlays.default =
    final: _prev:
    let
      collectAllNixFiles = dirPath: dirPath |> fs.fileFilter (file: file.hasExt "nix") |> fs.toList;
      fs = lib.fileset;
      inherit (final) lib;
    in
    {
      mkNima =
        {
          module ? { },
          featuresDir ? null,
          collect ? collectAllNixFiles,
          rawOutput ? false,
        }:
        lib.evalModules {
          class = "nima";
          modules = [
            final.pkgsModule
            (lib.modules.importApply ./_nima.nix { inherit featuresDir collect; })
            module
          ];
        }
        |> (if rawOutput then lib.id else x: x.config.finalPackage);
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
