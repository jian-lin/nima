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
          example = "misc.el";
          description = "Emacs lisp config file for this Emacs feature.";
        };
        order = mkOption {
          type = types.int;
          default = 0;
          description = ''
            Order affects Emacs feature mergeing.

            For example, Emacs lisp config with larger order comes later in default.el.
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
    features = mkOption {
      type = types.attrsOf featureModule;
      default = { };
      description = "Emacs features.";
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
        description = "Content of the generated default.el file.";
      };
      file = mkOption {
        type = types.package;
        internal = true;
        readOnly = true;
        default = pkgs.writeText "default.el" config.defaultEl.content;
        description = "Generated default.el file.";
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
          defaultElOverlay
        ];
        defaultElOverlay = final: _prev: {
          default = final.melpaBuild {
            pname = "default";
            version = "0.1.0";
            src = config.defaultEl.file;
            packageRequires = config.epkgs final;
            turnCompilationWarningToError = config.pedantic;
          };
        };
      in
      (epkgs: lib.optional (!isEmptyConfig) epkgs.default)
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
            elispConfig =
              if elisp != "" && elispFile != null then
                throw "nima: `feature.${name}.elisp` and `feature.${name}.elispFile` cannot be set together"
              else if elispFile != null then
                builtins.readFile elispFile
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
  };

  imports = [
    (lib.modules.importApply ./_import-features.nix importArgs)
  ];
}
