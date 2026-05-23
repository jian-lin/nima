{
  perSystem =
    {
      pkgs,
      lib,
      self',
      config,
      ...
    }:
    let
      mkDoc =
        { forInternalOptions }:
        (pkgs.nixosOptionsDoc {
          inherit (pkgs.mkNima { rawOutput = true; }) options;
          transformOptions = transformOptions forInternalOptions;
        }).optionsCommonMark;
      transformOptions =
        forInternalOptions: option:
        option |> hideNotOurs |> choose forInternalOptions |> formatDeclarationsAsRelativeLinksForOurs;
      isOurs =
        option:
        !lib.elem "_module" option.loc
        && lib.length option.declarations == 1
        && lib.hasPrefix builtins.storeDir (lib.head option.declarations);
      hideNotOurs = option: option // lib.optionalAttrs (!isOurs option) { visible = false; };
      choose =
        forInternalOptions: option:
        option
        // {
          internal = lib.xor option.internal forInternalOptions;
        };
      formatDeclarationsAsRelativeLinksForOurs =
        let
          # "/nix/store/hash-source/src/foo.nix" -> "src/foo.nix"
          stripStorePrefix =
            path:
            path
            |> lib.removePrefix builtins.storeDir
            |> lib.splitString "/"
            |> lib.drop 2
            |> lib.concatStringsSep "/";
        in
        option:
        option
        // lib.optionalAttrs (isOurs option) {
          declarations = map (declaration: {
            name = stripStorePrefix declaration;
            # prepending "/" makes it relative to the project root instead of the current file
            url = "/" + stripStorePrefix declaration;
          }) option.declarations;
        };
    in
    {
      config = {
        packages =
          config.nima.generatedDocs |> lib.mapAttrs (_name: cfg: mkDoc { inherit (cfg) forInternalOptions; });
        checks = config.nima.generatedDocs |> lib.mapAttrs (name: _cfg: self'.packages.${name});
      };
    };
}
