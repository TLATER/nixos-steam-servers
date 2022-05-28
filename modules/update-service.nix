{
  pkgs,
  lib,
  name,
  appId,
  steamUser,
  steamUserPasswordFile,
}: let
  inherit (builtins) readFile;
  inherit (lib.attrsets) nameValuePair optionalAttrs;
  inherit (lib.strings) concatStringsSep;
  inherit (pkgs) writeShellScriptBin;
  update-server = writeShellScriptBin "update-server" (readFile ../scripts/update-server.sh);
in
  nameValuePair "update-${name}" {
    description = "${name} game server updater";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];

    # Don't want to interrupt an ongoing download, and since
    # this is a oneshot the next invocation will be the new
    # one anyway.
    restartIfChanged = false;

    environment = {
      APP_ID = toString appId;
      STEAM_USER = steamUser;
    };
    path = [
      (pkgs.steamPackages.steamcmd.override {
        steamRoot = "/var/lib/${name}/.steamcmd";
      })
    ];

    serviceConfig =
      {
        Type = "oneshot";
        ExecStart = "${update-server}/bin/update-server";

        WorkingDirectory = "/var/lib/${name}";
        StateDirectory = "${name}";

        # Security settings
        DynamicUser = true;

        # Since steam uses namespaces to enable bundling its
        # shared libraries, we need to allow name spaces.
        # RestrictNamespaces = true;

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
            # "@mount"  See above note about namespaces
            "@obsolete"
            "@raw-io"
            "@reboot"
            # "@resources"  Ditto
            "@setuid"
            "@swap"
          ]);
        ProtectHome = "tmpfs";

        RemoveIPC = true;
        PrivateTmp = true;
        PrivateDevices = true;
        NoNewPrivileges = true;
        RestrictSUIDSGID = true;
        ProtectSystem = "strict";
        # Steam requires at least being able to write to $HOME.
        # ProtectHome = "read-only";
      }
      // (
        optionalAttrs (steamUser != "anonymous") {
          LoadCredential = "steam:${steamUserPasswordFile}";
        }
      );
  }
