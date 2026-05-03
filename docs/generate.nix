{
  perSystem =
    {
      pkgs,
      lib,
      config,
      self',
      ...
    }:
    {
      apps.genDocs = {
        type = "app";
        program = lib.getExe self'.packages.genDocs;
        meta.description = "Generate docs, pass `check` to error on diff";
      };

      packages.genDocs =
        pkgs.writeShellApplication {
          name = "gen-docs";
          runtimeInputs = [
            pkgs.coreutils
            pkgs.diffutils
          ];
          text = ''
            readonly docsDir="${config.nima.generatedDocsDir}"
            mkdir -p "$docsDir"

            newDocsDir="tmpDir-genDocs"
            mkdir -p "$newDocsDir"

            ${
              config.nima.generatedDocs
              |> lib.mapAttrsToList (
                name: cfg: ''ln -s "${self'.packages.${name}}" "$newDocsDir/${cfg.filename}"''
              )
              |> lib.concatStringsSep "\n"
            }

            if ! diff --unified --recursive "$docsDir" "$newDocsDir"; then
              rm -r "$docsDir"
              cp -r --dereference --no-preserve=mode "$newDocsDir" "$docsDir"
              rm -r "$newDocsDir"

              # in check mode, we error since there is diff
              [ -v 1 ] && exit 1
            else
              rm -r "$newDocsDir"
            fi
          '';
        }
        |> config.nima.lib.runInProjectRootWhenPossible;

      checks = { inherit (self'.packages) genDocs; };
    };
}
