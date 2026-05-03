{ featuresDir, collect }:

{ lib, ... }@moduleArgs:

let
  mkModule =
    modulePath:
    let
      thisFeature = mkFeatureName modulePath;
      moduleLike = import modulePath;
      module =
        if lib.isFunction moduleLike && lib.functionArgs moduleLike == { thisFeature = false; } then
          moduleLike { inherit thisFeature; }
        else
          moduleLike;
      appliedModule = applyModuleArgsIfFunction (toString modulePath) module moduleArgs;
    in
    if isStandardModule appliedModule modulePath then
      addModuleFileKeyIfNeeded modulePath appliedModule
    else
      # reduce boilerplate in feature files
      addModuleFileKeyIfNeeded modulePath { config.features.${thisFeature} = appliedModule; };

  mkFeatureName =
    modulePath:
    modulePath |> lib.baseNameOf |> lib.splitString "." |> lib.init |> lib.concatStringsSep ".";
  isStandardModule =
    module: modulePath:
    lib.throwIfNot (lib.isAttrs module) "nima: unsupported module ${modulePath}, see documentation for supported module syntax"
    <| module ? options || module ? config || module ? imports || module ? features;
  addModuleFileKeyIfNeeded =
    modulePath: module:
    module
    // {
      _file = module._file or toString modulePath;
      key = module.key or toString modulePath;
    };

  # vendor `lib.modules.applyModuleArgsIfFunction` to avoid eval warning of deprecation
  # maybe it'll be undeprecated in the future: https://github.com/NixOS/nixpkgs/issues/519074
  applyModuleArgsIfFunction =
    key: module: args:
    if lib.isFunction module then applyModuleArgs key module args else module;
  applyModuleArgs =
    key: module:
    args@{ config, ... }:
    let
      context = name: ''while evaluating the module argument `${name}` in "${key}":'';
      extraArgs = lib.mapAttrs (
        name: _hasDefault:
        lib.addErrorContext (context name)
          args.${name} or (lib.addErrorContext
            "noting that argument `${name}` is not externally provided, so querying `_module.args` instead, requiring `config`"
            config._module.args.${name}
          )
      ) (lib.functionArgs module);
    in
    module (args // extraArgs);
in
{
  imports =
    let
      modulePaths = collect featuresDir;
    in
    lib.optionals (featuresDir != null)
    <| lib.throwIfNot (lib.isFunction collect) "nima: `collect` must be a function"
    <| lib.throwIfNot (lib.isList modulePaths) "nima: `collect featuresDir` must be a list"
    <| map mkModule modulePaths;
}
