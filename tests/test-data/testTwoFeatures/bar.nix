{
  elispFile = ./bar.el;
  epkgs = epkgs: [ epkgs.myEldoc ];
  overlay = _final: prev: { myEldoc = prev.eldoc; };
}
