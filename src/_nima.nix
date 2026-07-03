importArgs:

{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    mkOption
    types
    literalExpression
    mkOptionType
    ;
  mergeSelectorFunctions = selectorFunctions: ps: lib.concatMap (select: select ps) selectorFunctions;
  selectorFunction = mkOptionType {
    name = "selectorFunction";
    description = "function that takes an attribute set (to select) and returns a list";
    check = x: lib.isFunction x && lib.isList (x { });
    merge = _loc: defs: mergeSelectorFunctions (lib.getValues defs);
  };
  mergeOverlayFunctions = lib.composeManyExtensions;
  overlayFunction = mkOptionType {
    name = "overlayFunction";
    check = x: lib.isFunction x && lib.isFunction (x { }) && lib.isAttrs (x { } { });
    merge = _loc: defs: mergeOverlayFunctions (lib.getValues defs);
  };
  epkgsOption = mkOption {
    type = selectorFunction;
    default = _epkgs: [ ];
    defaultText = literalExpression "epkgs: [ ]";
    example = literalExpression "epkgs: [ epkgs.magit ]";
    description = ''
      Emacs lisp packages to install.
      This can be (ab)used to provide executables, such as `pkgs.cowsay`, to Emacs.
    '';
  };
  overlayOption = mkOption {
    type = overlayFunction;
    default = _final: _prev: { };
    defaultText = literalExpression "final: prev: { }";
    description = "Overlay for Emacs lisp packages.";
  };
  featureModule = types.submodule (
    { name, ... }:
    {
      options = {
        name = mkOption {
          type = types.str;
          internal = true;
          readOnly = true;
          default = name;
          description = "Name of this Emacs feature.";
        };
        enable = lib.mkEnableOption "Emacs feature ${name}" // {
          default = true;
        };
        epkgs = epkgsOption; # TODO better naming?
        overlay = overlayOption;
        elisp = mkOption {
          type = types.str;
          default = "";
          example = "(foo-mode)";
          description = "Emacs lisp config for this Emacs feature.";
        };
        elispFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          defaultText = lib.literalMD ''
            If this feature is defined
            by a feature file
            under `featuresDir`,
            it defaults to the path of that feature file
            with `.nix` replaced by `.el`.

            Otherwise, it defaults to `null`.
          '';
          example = "./misc.el";
          description = "Emacs lisp config file for this Emacs feature.";
        };
        order = mkOption {
          type = types.int;
          default = 0;
          description = ''
            Order affects Emacs feature mergeing.

            For example, Emacs lisp config with larger order comes later
            in {file}`default.el`.
            A similar thing happens to `overlay`.
          '';
        };
      };
    }
  );
  sortedEnabledFeatures =
    config.features
    |> lib.attrValues
    |> lib.filter (lib.getAttr "enable")
    |> lib.sortOn (lib.getAttr "order");
  mergeFeatures =
    merge: attr: featureList:
    featureList |> map (lib.getAttr attr) |> merge;
in
{
  options = {
    package = lib.mkPackageOption pkgs "emacs" { };
    # early-default.el, unlike default.el, should be a very simple file
    # so we do not use "features" in its implementation
    # this simple implementation should work well
    earlyDefaultEl = {
      elisp = mkOption {
        type = types.str;
        default = "";
        example = ''
          (startup-redirect-eln-cache "my-eln-cache/")
        '';
        description = ''
          Emacs lisp config
          that is usually put in {file}`early-init.el`
          can be put here.

          This Emacs lisp config
          is used to generate {file}`early-default.el`,
          which is similar to {file}`early-init.el`.

          This option needs
          [a Nixpkgs PR](https://github.com/NixOS/nixpkgs/pull/536492)
          to function.
          Without that PR, this option is basically a no-op.

          To put things in {file}`default.el`
          (similar to {file}`init.el`),
          use {option}`features`.
        '';
      };
      content = mkOption {
        type = types.str;
        internal = true;
        readOnly = true;
        description = ''
          Content of generated {file}`early-default.el`
          (similar to {file}`early-init.el`).

          It consists of
          {option}`earlyDefaultEl.elisp`
          and
          Emacs lisp library boilerplate.
        '';
      };
      file = mkOption {
        type = types.package;
        internal = true;
        readOnly = true;
        default = pkgs.writeText "early-default.el" config.earlyDefaultEl.content;
        defaultText = lib.literalMD ''
          A generated file.  Its content is {option}`earlyDefaultEl.content`.
        '';
        description = ''
          Generated {file}`early-default.el`
          (similar to {file}`early-init.el`).
        '';
      };
    };
    features = mkOption {
      type = types.attrsOf featureModule;
      default = { };
      description = ''
        Emacs features.

        Emacs lisp config added here is put into {file}`default.el`
        (similar to {file}`init.el`).
        To put things in {file}`early-default.el`
        (similar to {file}`early-init.el`),
        use {option}`earlyDefaultEl`.
      '';
    };
    pedantic = lib.mkEnableOption "pedantic mode (failing on elisp compile warnings)";
    epkgs = epkgsOption // {
      internal = true;
    };
    overlay = overlayOption // {
      internal = true;
    };
    defaultEl = {
      content = mkOption {
        type = types.str;
        internal = true;
        readOnly = true;
        description = ''
          Content of generated {file}`default.el`
          (similar to {file}`init.el`).

          It consists of
          {option}`features.<name>.elisp` or {option}`features.<name>.elispFile`
          (when {option}`features.<name>.enable` is `true`)
          and
          Emacs lisp library boilerplate.
        '';
      };
      file = mkOption {
        type = types.package;
        internal = true;
        readOnly = true;
        default = pkgs.writeText "default.el" config.defaultEl.content;
        defaultText = lib.literalMD ''
          A generated file.  Its content is {option}`defaultEl.content`.
        '';
        description = ''
          Generated {file}`default.el`
          (similar to {file}`init.el`).
        '';
      };
    };
    finalPackage = mkOption {
      type = types.package;
      internal = true;
      readOnly = true;
      description = "The generated Emacs package to use.";
    };
  };

  config = {
    finalPackage =
      let
        isWrapped =
          emacs:
          lib.all (lib.flip lib.hasAttr emacs) [
            "explicitRequires"
            "deps"
          ];
        isEmptyConfig = isEmptyOverlay && isEmptyEpkgs && sortedEnabledFeatures == [ ];
        isEmptyOverlay = config.overlay { } { } == { };
        isEmptyEpkgs = config.epkgs { } == [ ];
        overlay' = mergeOverlayFunctions [
          config.overlay
          defaultElsOverlay
        ];
        defaultElsOverlay = final: _prev: {
          early-default = final.melpaBuild {
            pname = "early-default";
            version = "0.1.0";
            src = config.earlyDefaultEl.file;
            turnCompilationWarningToError = config.pedantic;
          };
          default = final.melpaBuild {
            pname = "default";
            version = "0.1.0";
            src = config.defaultEl.file;
            packageRequires = config.epkgs final;
            turnCompilationWarningToError = config.pedantic;
          };
        };
      in
      (
        epkgs:
        lib.optional (config.earlyDefaultEl.elisp != "") epkgs.early-default
        ++ lib.optional (!isEmptyConfig) epkgs.default
      )
      |> (config.package.pkgs.overrideScope overlay').withPackages
      |> lib.throwIf (isWrapped config.package) "nima: `package` must be unwrapped Emacs, such as pkgs.emacs or pkgs.emacs-nox";

    epkgs = mergeFeatures mergeSelectorFunctions "epkgs" sortedEnabledFeatures;
    overlay = mergeFeatures mergeOverlayFunctions "overlay" sortedEnabledFeatures;
    defaultEl.content = ''
      ;;; default.el --- The default.el file  -*- lexical-binding: t; -*-

      ;; Version: 0.1.0
      ;; Keywords: local

      ;;; Commentary:

      ;;; Code:

      ${
        sortedEnabledFeatures
        |> map (
          {
            name,
            elisp,
            elispFile,
            ...
          }:
          let
            elispFileContent =
              if elispFile == null || !lib.pathExists elispFile then "" else builtins.readFile elispFile;
            elispConfig =
              if elisp != "" && elispFileContent != "" then
                throw "nima: `feature.${name}.elisp` and `feature.${name}.elispFile` (${toString elispFile}) cannot be set together"
              else if elispFileContent != "" then
                elispFileContent
              else
                elisp;
          in
          ";;;; ${name}\n\n${elispConfig}\n"
        )
        |> lib.concatStringsSep "\n"
      }

      ;; Local Variables:
      ;; eval: (outline-minor-mode)
      ;; End:

      (provide 'default)

      ;;; default.el ends here
    '';
    earlyDefaultEl.content = ''
      ;;; early-default.el --- The early-default.el file  -*- lexical-binding: t; -*-

      ;; Version: 0.1.0
      ;; Keywords: local

      ;;; Commentary:

      ;;; Code:

      ${config.earlyDefaultEl.elisp}

      ;; Local Variables:
      ;; eval: (outline-minor-mode)
      ;; End:

      (provide 'early-default)

      ;;; early-default.el ends here
    '';
  };

  imports = [
    (lib.modules.importApply ./_import-features.nix importArgs)
  ];
}
