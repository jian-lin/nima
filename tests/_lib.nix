{ lib }:

{
  isWrappedEmacs = wrappedEmacs: [
    (lib.isStorePath wrappedEmacs.drvPath)
    (lib.isDerivation wrappedEmacs)
    (lib.hasInfix "emacs" wrappedEmacs.name)
    (lib.hasInfix "with-packages" wrappedEmacs.name)
    (lib.hasAttr "deps" wrappedEmacs)
    (lib.hasAttr "emacs" wrappedEmacs)
    (lib.isDerivation wrappedEmacs.emacs)
    (lib.hasInfix "emacs" wrappedEmacs.emacs.name)
  ];
  defaultElRequires =
    epkg: wrappedEmacs: lib.elem epkg wrappedEmacs.emacs.pkgs.default.packageRequires;
  defaultElContains =
    elisp: wrappedEmacs: lib.hasInfix elisp wrappedEmacs.emacs.pkgs.default.src.text;
  defaultElMatches =
    pattern: wrappedEmacs: lib.match pattern wrappedEmacs.emacs.pkgs.default.src.text != null;
}
