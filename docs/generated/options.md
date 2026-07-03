## package



The emacs package to use\.



*Type:*
package



*Default:*

```nix
pkgs.emacs
```

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)



## earlyDefaultEl\.elisp

Emacs lisp config
that is usually put in ` early-init.el `
can be put here\.

This Emacs lisp config
is used to generate ` early-default.el `,
which is similar to ` early-init.el `\.

This option needs
[a Nixpkgs PR](https://github\.com/NixOS/nixpkgs/pull/536492)
to function\.
Without that PR, this option is basically a no-op\.

To put things in ` default.el `
(similar to ` init.el `),
use ` features `\.



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
''
  (startup-redirect-eln-cache "my-eln-cache/")
''
```

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)



## features



Emacs features\.

Emacs lisp config added here is put into ` default.el `
(similar to ` init.el `)\.
To put things in ` early-default.el `
(similar to ` early-init.el `),
use ` earlyDefaultEl `\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)



## features\.\<name>\.enable



Whether to enable Emacs feature ‹name›\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)



## features\.\<name>\.elisp



Emacs lisp config for this Emacs feature\.



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"(foo-mode)"
```

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)



## features\.\<name>\.elispFile



Emacs lisp config file for this Emacs feature\.



*Type:*
null or absolute path



*Default:*
If this feature is defined
by a feature file
under ` featuresDir `,
it defaults to the path of that feature file
with ` .nix ` replaced by ` .el `\.

Otherwise, it defaults to ` null `\.



*Example:*

```nix
"./misc.el"
```

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)



## features\.\<name>\.epkgs



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



## features\.\<name>\.order



Order affects Emacs feature mergeing\.

For example, Emacs lisp config with larger order comes later
in ` default.el `\.
A similar thing happens to ` overlay `\.



*Type:*
signed integer



*Default:*

```nix
0
```

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)



## features\.\<name>\.overlay



Overlay for Emacs lisp packages\.



*Type:*
overlayFunction



*Default:*

```nix
final: prev: { }
```

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)



## pedantic



Whether to enable pedantic mode (failing on elisp compile warnings)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [src/_nima\.nix](/src/_nima.nix)


