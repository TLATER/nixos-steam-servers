{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) readFile foldl';
  inherit (lib) mkOption types literalExpression;
  inherit (lib.attrsets) mapAttrs';
  inherit (lib.debug) traceVal;
in {
  options.steam-servers = {
    servers = mkOption {
      default = {};
      type = types.attrsOf (types.submodule (import ./gameserverOptions.nix));
      description = "Steam game servers to manage.";
      example = literalExpression ''
        {
          starbound = {
            appId = 211820;
            startScript = '''
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

  config = {
    systemd.services = let
      mapServers = f:
        mapAttrs' (name: config:
          f (
            if config.name != null
            then config.name
            else name
          )
          config)
        config.steam-servers.servers;
    in
      foldl' (a: b: a // b) {} [
        (mapServers (
          name: config:
            import ./update-service.nix {
              inherit pkgs lib name;
              inherit (config) appId steamUser steamUserPasswordFile;
            }
        ))

        (mapServers (
          name: config:
            import ./game-service.nix {
              inherit lib name;
              inherit (config) startScript;
            }
        ))
      ];
  };
}
