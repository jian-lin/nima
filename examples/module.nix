{
  perSystem =
    {
      lib,
      pkgs,
      ...
    }:
    let
      mkExamples =
        {
          forCI ? false,
        }:
        examplesDir
        |> builtins.readDir
        |> lib.filterAttrs (_name: type: type == "directory")
        |> lib.mapAttrs' (name: _type: lib.nameValuePair (mkName name) (mkExample forCI name));
      examplesDir = ./nima-modules;
      mkName = name: lib.toCamelCase "example ${name}";
      mkExample =
        forCI: name:
        let
          thisExampleDir = lib.path.append examplesDir name;
        in
        pkgs.mkNima {
          module = {
            imports = [ thisExampleDir ];
            pedantic = lib.mkIf forCI (lib.mkForce true);
          };
          featuresDir = lib.path.append thisExampleDir "features";
        };
    in
    {
      packages = mkExamples { };

      checks = mkExamples { forCI = true; };
    };
}
