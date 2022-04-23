{
  config,
  pkgs,
  lib,
  ...
}: {
  systemd.services.steamcmd-update = {
    description = "Steam game server update service";
    after = ["network.target"];

    serviceConfig = {

    };
  };
}
