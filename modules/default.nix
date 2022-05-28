{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) readFile foldl';
  inherit (lib) mkOption types literalExpression;
  inherit (lib.attrsets) mapAttrs';
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
    systemd.services =
      mapAttrs' (
        n: config: let
          inherit (config) appId steamUser steamUserPasswordFile;
          name =
            if config.name != null
            then config.name
            else n;
        in
          foldl' (a: b: a // b) {} [
            # Update services
            (import ./update-service.nix {
              inherit pkgs lib name appId steamUser steamUserPasswordFile;
            })

            # Actual game server services
            (import ./game-service.nix {
              inherit lib startScript;
            })
          ]
      )
      config.steam-servers.servers;
  };
}
