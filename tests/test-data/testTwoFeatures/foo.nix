{
  elisp = "(defvar foo 1)";
  epkgs = epkgs: [ epkgs.myEglot ];
  overlay = _final: prev: { myEglot = prev.eglot; };
}
