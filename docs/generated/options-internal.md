## defaultEl\.content

Content of the generated default\.el file\.



*Type:*
string *(read only)*

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)



## defaultEl\.file



Generated default\.el file\.



*Type:*
package *(read only)*



*Default:*

```nix
<derivation default.el>
```

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)



## epkgs



Emacs lisp packages to install\.
This can be (ab)used to provide executables, such as ` pkgs.cowsay `, to Emacs\.



*Type:*
function that takes an attribute set (to select) and returns a list



*Default:*

```nix
epkgs: [ ]
```



*Example:*

```nix
epkgs: [ epkgs.magit ]
```

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)



## features\.\<name>\.name



Name of this Emacs feature\.



*Type:*
string *(read only)*



*Default:*

```nix
"‹name›"
```

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)



## finalPackage



The generated Emacs package to use\.



*Type:*
package *(read only)*

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)



## overlay



Overlay for Emacs lisp packages\.



*Type:*
overlayFunction



*Default:*

```nix
final: prev: { }
```

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)


