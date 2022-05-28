{
  lib,
  name,
  startScript,
}: let
  inherit (lib.attrsets) nameValuePair;
  inherit (lib.strings) concatStringsSep;
in
  nameValuePair "steam-${name}" {
    description = "${name} game server";
    after = ["update-${name}.service"];
    script = startScript;

    serviceConfig = {
      WorkingDirectory = "/var/lib/${name}";
      StateDirectory = "${name}";

      # Security settings
      DynamicUser = true;

      RestrictNamespaces = true;
      PrivateUsers = true;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = ["AF_UNIX AF_INET AF_INET6"];
      LockPersonality = true;
      RestrictRealtime = true;
      SystemCallFilter =
        "~"
        + (concatStringsSep " " [
          "@clock"
          "@cpu-emulation"
          "@debug"
          "@keyring"
          "@memlock"
          "@module"
          "@mount"
          "@obsolete"
          "@raw-io"
          "@reboot"
          "@resources"
          "@setuid"
          "@swap"
        ]);

      RemoveIPC = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      RestrictSUIDSGID = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  }
