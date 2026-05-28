{
  # we can use `elispFile` when we do not need to access the nix world in our elisp config
  elispFile = ./prelude.el; # this is the default value, so it can be commented out / removed
  order = -100; # make this elisp config come first in the generated default.el
}
