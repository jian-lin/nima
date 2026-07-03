{ pkgs, ... }:

{
  package = pkgs.emacs-pgtk; # choose your Emacs variant

  # you can think this as early-init.el
  earlyDefaultEl.elisp = ''
    (startup-redirect-eln-cache "my-eln-cache/")
  '';
}
