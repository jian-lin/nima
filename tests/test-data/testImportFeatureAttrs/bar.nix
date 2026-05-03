{ thisFeature }:

{
  config.features.${thisFeature} = {
    elisp = "(defvar bar 2)";
  };
}
