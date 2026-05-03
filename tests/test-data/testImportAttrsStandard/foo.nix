{
  features.foo = {
    elisp = "(defvar foo 1)";
    epkgs = epkgs: [ epkgs.eldoc ];
  };
}
