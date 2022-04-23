{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  gameserverOptions = import ./gameserverOptions.nix;
in {
  options.services.steam-servers = {
    servers = mkOption {
      default = {};
      type = types.attrsOf (types.submodule gameserverOptions);
      description = "Steam game servers to manage.";
      example = literalExpression ''
        {
          starbound = {
            app_id = "211820";
            start = '''
              cp ''${configuration} storage/starbound_server.config
              cd linux
              patchelf --set-interpreter ''${stdenv.cc.bintools.dynamicLinker} \
                  ./starbound_server
              ./starbound_server
            ''';
          };
        }
      '';
    };
  };
}
