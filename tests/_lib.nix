{ lib }:

let
  elContains =
    package: elisp: wrappedEmacs:
    lib.hasInfix elisp wrappedEmacs.emacs.pkgs.${package}.src.text;
in
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
  defaultElContains = elContains "default";
  defaultElMatches =
    pattern: wrappedEmacs: lib.match pattern wrappedEmacs.emacs.pkgs.default.src.text != null;
  earlyDefaultElContains = elContains "early-default";
  epkgsNumber = wrappedEmacs: lib.length wrappedEmacs.explicitRequires;
  epkgsNameAt =
    index: wrappedEmacs:
    let
      sortedEpkgs = lib.sortOn (lib.getAttr "pname") wrappedEmacs.explicitRequires;
    in
    (lib.elemAt sortedEpkgs index).pname;
}
