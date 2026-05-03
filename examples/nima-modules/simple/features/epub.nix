{ lib, pkgs, ... }:

{
  epkgs = epkgs: [
    epkgs.nov # add/install Emacs lisp packages
    pkgs.epub2txt2 # Emacs will be able to find its binary
  ];

  # change Emacs lisp packages
  overlay = _final: prev: {
    nov = prev.nov.overrideAttrs (
      _finalAttrs: previousAttrs: {
        patches = previousAttrs.patches or [ ] ++ [
          # my.patch
        ];
      }
    );
  };

  elisp = ''
    ;; we have access to the nix world
    (setopt nov-unzip-program "${lib.getExe pkgs.unzip}")

    ;; `my-emacs-data-directory' is defined in the "prelude" feature
    (setopt nov-save-place-file (expand-file-name "nov-places" my-emacs-data-directory))

    ;; `cl-pushnew' is part of `cl-lib' which is loaded in the "prelude" feature
    (cl-pushnew '("\\.epub\\'" . nov-mode)
                auto-mode-alist
                :test #'equal)
  '';
}
