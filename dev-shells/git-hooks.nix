{ inputs, ... }:

{
  imports = [ inputs.git-hooks-nix.flakeModule ];

  perSystem =
    {
      lib,
      self',
      config,
      ...
    }:
    {
      pre-commit = {
        settings.hooks = {
          # keep-sorted start block=yes
          checkLocalFileLinks = {
            enable = true;
            name = "Check local file links (files pointed to do exist)";
            entry = "${self'.apps.checkLinks.program} --no-progress --offline";
            types = [ "text" ];
            language = "unsupported";
          };
          genDocsWhenNeeded = {
            enable = true;
            name = "Generate docs when needed";
            entry = "${self'.apps.genDocs.program} check";
            files = "^src/";
            types = [ "nix" ];
            pass_filenames = false;
            language = "unsupported";
          };
          markdownlint = {
            enable = true;
            settings.configuration = {
              # for folding
              MD033.allowed_elements = [
                "details"
                "summary"
              ];
            };
            excludes =
              config.nima.generatedDocs
              |> lib.mapAttrsToList (_name: cfg: "${config.nima.generatedDocsDir}/${cfg.filename}");
          };
          treefmt.enable = true;
          # keep-sorted end
        };
      };
    };
}
