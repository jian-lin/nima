{ pkgs, ... }:

{
  package = pkgs.emacs; # choose your Emacs variant, such as pkgs.emacs-pgtk

  # you can think this as early-init.el
  earlyDefaultEl.elisp = ''
    (startup-redirect-eln-cache "my-eln-cache/")
  '';
}
