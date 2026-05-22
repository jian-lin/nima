{
  perSystem =
    { pkgs, lib, ... }:
    {
      apps.zizmor = {
        type = "app";
        meta.description = "Pre-configured zizmor";
        program =
          let
            args = [
              "--strict-collection"
              "--persona=auditor"
              "--no-config"
              "--show-audit-urls=always"
            ];
          in
          pkgs.writeShellApplication {
            name = "zizmor-with-config";
            runtimeInputs = [ pkgs.zizmor ];
            text = ''
              zizmor ${lib.escapeShellArgs args} "$@"
            '';
          };
      };
    };
}
