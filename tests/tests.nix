{
  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    {
      nix-unit.tests =
        let
          t = import ./_lib.nix { inherit lib; };
        in
        {
          shouldFail = {
            testDoubleWrapping = {
              expr = pkgs.mkNima {
                module = {
                  package = pkgs.emacs.pkgs.withPackages (_epkgs: [ ]);
                };
              };
              expectedError = {
                type = "ThrownError";
                msg = "must be unwrapped Emacs";
              };
            };
            testBothElispFileAndElisp = {
              expr = pkgs.mkNima { featuresDir = ./test-data/testBothStringAndFile; };
              expectedError = {
                type = "ThrownError";
                msg = "cannot be set together";
              };
            };
            importFeatures = {
              testCollectNotFunction = {
                expr = pkgs.mkNima {
                  featuresDir = ./test-data/testOneFeature;
                  collect = true;
                };
                expectedError = {
                  type = "ThrownError";
                  msg = "must be a function";
                };
              };
              testCollectNotReturnList = {
                expr = pkgs.mkNima {
                  featuresDir = ./test-data/testOneFeature;
                  collect = _dir: true;
                };
                expectedError = {
                  type = "ThrownError";
                  msg = "must be a list";
                };
              };
            };
          };
          shouldSucceed = {
            testEmptyConfig = {
              expr =
                (pkgs.mkNima {
                  module = {
                    package = pkgs.emacs;
                  };
                }).drvPath;
              expected = (pkgs.emacs.pkgs.withPackages (_epkgs: [ ])).drvPath;
            };
            testEnablePedantic = {
              expr =
                (pkgs.mkNima {
                  module = {
                    pedantic = true;
                  };
                }).emacs.pkgs.default.turnCompilationWarningToError;
              expected = true;
            };
            features = {
              testDisableFeature = {
                expr =
                  (pkgs.mkNima {
                    module = {
                      package = pkgs.emacs;
                    };
                    featuresDir = ./test-data/testDisableFeature;
                  }).drvPath;
                expected = (pkgs.emacs.pkgs.withPackages (_epkgs: [ ])).drvPath;
              };
              testOneFeature =
                let
                  inherit (pkgs) emacs;
                  wrappedEmacs = pkgs.mkNima {
                    module = {
                      package = emacs;
                    };
                    featuresDir = ./test-data/testOneFeature;
                  };
                in
                [
                  (emacs.pkgs.eglot == wrappedEmacs.emacs.pkgs.myEglot)
                  (t.defaultElRequires emacs.pkgs.eglot wrappedEmacs)
                  (t.defaultElContains "(defvar foo 1)" wrappedEmacs)
                ]
                ++ t.isWrappedEmacs wrappedEmacs
                |> lib.testAllTrue;
              testTwoFeatures =
                let
                  inherit (pkgs) emacs;
                  wrappedEmacs = pkgs.mkNima {
                    module = {
                      package = emacs;
                    };
                    featuresDir = ./test-data/testTwoFeatures;
                  };
                in
                [
                  (emacs.pkgs.eglot == wrappedEmacs.emacs.pkgs.myEglot)
                  (t.defaultElRequires emacs.pkgs.eglot wrappedEmacs)
                  (t.defaultElContains "(defvar foo 1)" wrappedEmacs)
                ]
                ++ [
                  (emacs.pkgs.eldoc == wrappedEmacs.emacs.pkgs.myEldoc)
                  (t.defaultElRequires emacs.pkgs.eldoc wrappedEmacs)
                  (t.defaultElContains "(defvar bar 1)" wrappedEmacs)
                ]
                ++ t.isWrappedEmacs wrappedEmacs
                |> lib.testAllTrue;
              testNeitherElispFileNorElisp =
                let
                  inherit (pkgs) emacs;
                  wrappedEmacs = pkgs.mkNima {
                    module = {
                      package = emacs;
                    };
                    featuresDir = ./test-data/testNeitherStringNorFile;
                  };
                in
                [
                  (t.defaultElRequires emacs.pkgs.eldoc wrappedEmacs)
                ]
                ++ t.isWrappedEmacs wrappedEmacs
                |> lib.testAllTrue;
              order = {
                testDefaultOrder =
                  let
                    wrappedEmacs = pkgs.mkNima { featuresDir = ./test-data/testDefaultOrder; };
                  in
                  [
                    (t.defaultElMatches ".*defvar bar 1.*defvar foo 1.*" wrappedEmacs)
                    (wrappedEmacs.emacs.pkgs.someNumber == 3)
                  ]
                  |> lib.testAllTrue;
                testExplicitOrder =
                  let
                    wrappedEmacs = pkgs.mkNima { featuresDir = ./test-data/testExplicitOrder; };
                  in
                  [
                    (t.defaultElMatches ".*defvar foo 1.*defvar bar 1.*" wrappedEmacs)
                    (wrappedEmacs.emacs.pkgs.someNumber == 3)
                  ]
                  |> lib.testAllTrue;
              };
              dependOnOtherFeature = {
                testDependOnEnabledFeature =
                  let
                    wrappedEmacs = pkgs.mkNima { featuresDir = ./test-data/testDependOnEnabledFeature; };
                  in
                  [
                    (t.defaultElContains "(defvar foo 1)" wrappedEmacs)
                    (!t.defaultElContains "(defvar bar 1)" wrappedEmacs)
                  ]
                  |> lib.testAllTrue;
                testDependOnDisabledFeature =
                  let
                    wrappedEmacs = pkgs.mkNima { featuresDir = ./test-data/testDependOnDisabledFeature; };
                  in
                  [
                    (!t.defaultElContains "(defvar foo 1)" wrappedEmacs)
                    (t.defaultElContains "(defvar bar 1)" wrappedEmacs)
                  ]
                  |> lib.testAllTrue;
              };
            };
            import = {
              testImportFeatureFunction =
                let
                  wrappedEmacs = pkgs.mkNima { featuresDir = ./test-data/testImportFeatureFunction; };
                in
                [
                  (t.defaultElContains "(defvar foo 1)" wrappedEmacs)
                  (t.defaultElRequires pkgs.cowsay wrappedEmacs)
                ]
                |> lib.testAllTrue;
              testImportFeatureAttrs =
                let
                  inherit (pkgs) emacs;
                  wrappedEmacs = pkgs.mkNima {
                    module = {
                      package = emacs;
                    };
                    featuresDir = ./test-data/testImportFeatureAttrs;
                  };
                in
                [
                  (t.defaultElContains "(defvar foo 1)" wrappedEmacs)
                  (t.defaultElRequires emacs.pkgs.eldoc wrappedEmacs)
                  (t.defaultElContains "(defvar bar 2)" wrappedEmacs)
                ]
                |> lib.testAllTrue;
              testImportFunctionStandard =
                let
                  wrappedEmacs = pkgs.mkNima { featuresDir = ./test-data/testImportFunctionStandard; };
                in
                [
                  (t.defaultElContains "(defvar foo 1)" wrappedEmacs)
                  (t.defaultElRequires pkgs.cowsay wrappedEmacs)
                ]
                |> lib.testAllTrue;
              testImportAttrsStandard =
                let
                  inherit (pkgs) emacs;
                  wrappedEmacs = pkgs.mkNima {
                    module = {
                      package = emacs;
                    };
                    featuresDir = ./test-data/testImportAttrsStandard;
                  };
                in
                [
                  (t.defaultElContains "(defvar foo 1)" wrappedEmacs)
                  (t.defaultElRequires emacs.pkgs.eldoc wrappedEmacs)
                  (t.defaultElContains "(defvar bar 2)" wrappedEmacs)
                ]
                |> lib.testAllTrue;
              testImportModuleDeduplication =
                let
                  result = pkgs.mkNima' {
                    module = {
                      imports = [
                        { config.fooList2 = [ 2 ]; }
                        { config.fooList2 = [ 2 ]; }
                      ];
                    };
                    featuresDir = ./test-data/testImportModuleDeduplication;
                  };
                in
                [
                  (result.config.fooList1 == [ 1 ])
                  (
                    result.config.fooList2 == [
                      2
                      2
                    ]
                  )
                ]
                |> lib.testAllTrue;
              testModuleDefinitionLocation =
                let
                  result = pkgs.mkNima' { featuresDir = ./test-data/testModuleDefinitionLocation; };
                  getFile =
                    feature:
                    lib.head result.options.features.valueMeta.attrs.${feature}.configuration.options.order.files;
                  checkDefinitionLocation =
                    feature: lib.hasInfix "testModuleDefinitionLocation/${feature}.nix" (getFile feature);
                in
                [
                  (checkDefinitionLocation "foo-attrs")
                  (checkDefinitionLocation "foo-attrs-standard")
                  (checkDefinitionLocation "foo-attrs-thisFeature")
                  (checkDefinitionLocation "foo-function")
                  (checkDefinitionLocation "foo-function-standard")
                  (checkDefinitionLocation "foo-function-thisFeature")
                ]
                |> lib.testAllTrue;
            };
          };
        };
    };
}
