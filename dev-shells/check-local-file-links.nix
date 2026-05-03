{
  perSystem =
    {
      lib,
      pkgs,
      self',
      config,
      ...
    }:
    {
      apps.checkLinks = {
        type = "app";
        meta.description = "Check local and remote links in this project";
        program = lib.getExe self'.packages.checkLinks;
      };

      packages.checkLinks =
        let
          configFile = (pkgs.formats.toml { }).generate "lychee.toml" {
            root_dir = ".";
            include_fragments = true;
            include_verbatim = true;
            require_https = true;
          };
        in
        pkgs.writeShellApplication {
          name = "check-links";
          runtimeInputs = [ pkgs.lychee ];
          text = ''
            if ! [ -r "''${SSL_CERT_FILE-}" ]; then
              # lychee insists on reading CA certs, even when it makes no network connection
              # probably, here we are in the nix build sandbox (run by `nix flake check`)
              # the sandbox has an empty cert which lychee dislikes
              # this makes lychee happy
              SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
            fi

            lychee --config ${configFile} "$@"
          '';
        }
        |> config.nima.lib.runInProjectRootWhenPossible;

      checks = { inherit (self'.packages) checkLinks; };
    };
}
