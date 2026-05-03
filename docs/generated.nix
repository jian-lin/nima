{
  perSystem =
    { lib, ... }:
    let
      inherit (lib) mkOption types;
      generatedDocModule = types.submodule {
        options = {
          forInternalOptions = mkOption {
            type = types.bool;
            readOnly = true;
            description = "Whether this doc is for internal options.";
          };
          filename = mkOption {
            type = types.str;
            readOnly = true;
            description = "Filename of the generated doc after it is copied into the project.";
          };
        };
      };
    in
    {
      options.nima = {
        generatedDocs = mkOption {
          type = types.attrsOf generatedDocModule;
          readOnly = true;
          description = "Generated docs.";
        };
        generatedDocsDir = mkOption {
          type = types.pathWith {
            absolute = false;
            inStore = false;
          };
          readOnly = true;
          description = ''
            Generated docs are copied into the project under this dir.
            It is relative to the project root.
          '';
        };
      };

      config.nima = {
        generatedDocsDir = "docs/generated";
        generatedDocs = {
          doc = {
            forInternalOptions = false;
            filename = "options.md";
          };
          docInternal = {
            forInternalOptions = true;
            filename = "options-internal.md";
          };
        };
      };
    };
}
