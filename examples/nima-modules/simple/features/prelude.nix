{
  # we can use `elispFile` when we do not need to access the nix world in our elisp config
  elispFile = ./prelude.el;
  order = -100; # make this elisp config come first in the generated default.el
}
