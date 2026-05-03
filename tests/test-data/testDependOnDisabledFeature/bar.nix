{ config, ... }:

{
  enable = !config.features.foo.enable;
  elisp = "(defvar bar 1)";
}
