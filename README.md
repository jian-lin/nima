# nima - Configure Emacs, Declaratively

A thin wrapper around Nixpkgs `emacs.pkgs.withPackages`
using the [module system]
with some footguns[^footgun] removed

[module system]: https://nix.dev/tutorials/module-system/
[^footgun]: Such as using `emacs.pkgs.withPackages` or [its wrappers](#related-work) more than once.

## Getting started

`nima` provides `mkNima` function
through a Nixpkgs [overlay].

[overlay]: https://wiki.nixos.org/wiki/Overlays#Using_overlays

`mkNima` takes an attribute set as argument:

```nix
{
  module ? { },
  featuresDir ? null,
  collect ? collectAllNixFiles,
  rawOutput ? false
}
```

- `module` is a `nima` [module].
- `featuresDir` is a directory
  containing [`nima` features](#nima-feature).
- `collect` is a function taking a directory
  and returning a list of `nima` feature file paths in that directory.
  It is used to collect `nima` feature files in `featuresDir`
  when `featuresDir` is not `null`.
  The default `collect` function collects all `.nix` files
  in the directory.
  `featuresDir` must be of type [path]
  when using the default `collect` function.
  You may find [lib.fileset] useful when writing your own `collect` function.
- `rawOutput` defaults to `false` and
  `mkNima` returns a configured Emacs.
  When `rawOutput` is `true`,
  `mkNima` returns the raw output of `lib.evalModules`,
  which is an attribute set.
  Taking `config.finalPackage` from that attribute set
  and you get a configured Emacs,
  which is exactly the return value of `mkNima` when `rawOutput` is `false`.
  Setting `rawOutput` to `true` is for advanced use cases
  such as debugging by inspecting values of `nima` options in [nix repl]
  and modifying an already `nima`-configured Emacs via `extendModules`.

[module]: https://nix.dev/tutorials/module-system/a-basic-module/
[path]: https://nix.dev/manual/nix/latest/language/types.html#type-path
[lib.fileset]: https://nix.dev/tutorials/working-with-local-files
[nix repl]: https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-repl.html

See [option documentation](/docs/generated/options.md)
for available module options.

> [!TIP]
> There are also [internal options](/docs/generated/options-internal.md)
> useful for debugging.
> Set `rawOutput` to `true` to get access to them.

### `nima` feature

Each file under `featuresDir` directory configures a `nima` feature.

Each file is a `nima` [module] like this

```nix
# epub.nix
{ pkgs, ... }:

{
  features.epub = {
    elisp = "...";
    epkgs = epkgs: [
      epkgs.nov
      pkgs.epub2txt2
    ];
  };
}
```

The feature `<name>` in `features.<name>`
is almost always the same as
the file name with `.nix` stripped.
For example, in the above file,
the feature is `epub`
and the file is named `epub.nix`.
To reduce duplication, we can also write the above file like this

```nix
# epub.nix
{ thisFeature }:

{ pkgs, ... }:

{
  features.${thisFeature} = {
    elisp = "...";
    epkgs = epkgs: [
      epkgs.nov
      pkgs.epub2txt2
    ];
  };
}
```

> [!IMPORTANT]
> `{ thisFeature }:` has to be written exactly like this.
> For example, `thisFeature:` does not work.

Most of the time,
each feature file contains only `features.<name>`.
In that case, we can further simplify the above file like this

```nix
# epub.nix
{ pkgs, ... }:

{
  elisp = "...";
  epkgs = epkgs: [
    epkgs.nov
    pkgs.epub2txt2
  ];
}
```

> [!TIP]
> Module arguments, such as `{ pkgs, ... }:`, can be omitted if not needed.

## Examples

Take a look at these [annotated examples](/examples/nima-modules/)
to get a feeling of
what `nima` configurations look like
and how to configure a `nima` [feature](/docs/generated/options.md#features).

Try out Emacsen configured by those examples using commands like

```console
HOME=$(mktemp -d) nix run github:jian-lin/nima#exampleSimple
```

## Status

The author dogfoods `nima`
and will make necessary changes in the future
to keep `nima` working.

`nima` serves the author well,
so presumably the author will not add new features.
However, if there is a feature wanted by many people,
the author may consider adding it.
In addition, pull requests are welcome.

## Non-goals

- Configure `early-init.el`:
  this cannot be done in `nima`,
  but you can do it outside of `nima`
  using things like `systemd.tmpfiles` NixOS module option
- Configure Emacs daemon service:
  this is beyond the scope of `nima`,
  which is configuring Emacs proper

## Related work

- `emacs.pkgs.withPackages` of Nixpkgs
- [programs.emacs] of [Home Manager]
- [emacsWithPackagesFromUsePackage] of [emacs-overlay]

[programs.emacs]: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.emacs.enable
[emacsWithPackagesFromUsePackage]: https://github.com/nix-community/emacs-overlay#extra-library-functionality
[Home Manager]: https://github.com/nix-community/home-manager
[emacs-overlay]: https://github.com/nix-community/emacs-overlay

<details> <summary>details</summary>

### `emacs.pkgs.withPackages` of Nixpkgs

Most things using Nix to configure Emacs,
including `nima`,
are wrappers of `emacs.pkgs.withPackages`.

If you are a happy user of `emacs.pkgs.withPackages`,
you can continue using it.

When you want to make your Emacs configuration more modular
or want some extra functionalities,
have a look at its wrappers.

### [programs.emacs] of [Home Manager]

`programs.emacs` also uses the [module system].
`nima` and it have different designs,
resulting in different ways to organize your Emacs configuration.
`nima` encourages a more modular way.

In addition, `nima` is not tied to a specific module system
while `programs.emacs` is part of Home Manager.

### [emacsWithPackagesFromUsePackage] of [emacs-overlay]

`emacsWithPackagesFromUsePackage` does not use the [module system].
As a result, `nima` configurations can be more modular,
have better error messages and better merging behavior.

`nima` allows you to write Emacs configuration using the way you like,
while `emacsWithPackagesFromUsePackage` is tied to `use-package`.

By focusing on `use-package`, `emacsWithPackagesFromUsePackage` can
automatically find Emacs lisp package dependencies.
`nima` cannot do that
because it is impossible for configurations not using `use-package`.

`emacsWithPackagesFromUsePackage` supports writing your Emacs configuration
in [literate programming] using Org Babel.
With `nima`, your Emacs configuration
is organized with `.nix` and optional `.el` files.
Literate programming support can be added in the future
if it is wanted by many people.

[literate programming]: https://en.wikipedia.org/wiki/Literate_programming

`nima` generates one single `.el` file from your configuration.
Generally, you do not need to read that generated file.
But if you do, maybe for debugging,
`nima` has you covered
with the help of `outline-minor-mode` to ease navigation.

</details>

## License

[AGPL-3.0-or-later](https://spdx.org/licenses/AGPL-3.0-or-later.html)
