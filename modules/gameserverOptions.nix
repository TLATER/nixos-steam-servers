{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options = {
    # TODO: Use
    autoStart = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Automatically start the game server after the network comes up.
      '';
    };

    name = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Name of the game server. Defaults to its attribute name.

        Only used for naming server directories and services. No special
        effort has to be made for this to be a recognizable name.

        It is in fact possible to run multiple servers of the same game with
        different names, as long as they are configured to use different
        ports.
      '';
      example = "starbound";
    };

    appId = mkOption {
      type = types.int;
      description = ''
        App ID of the game. Look for the number in the URL of the game's store
        page.
      '';
      example = "211820";
    };

    steamUser = mkOption {
      type = types.str;
      description = ''
        Name of the steam user to be used for authentication.

        Defaults to `anonymous`. Only change this for servers which *require*
        sign-in, and if you do, use an account created with
        https://steamcommunity.com/dev/managegameservers.
      '';
      default = "anonymous";
    };

    # TODO: Use
    extraSteamCommands = mkOption {
      type = types.nullOr types.lines;
      default = null;
      description = ''
        Additional commands to run during `steamcmd` execution, to
        e.g. install mods.

        These commands will be repeated every time the server is
        updated.

        Commands are written directly to the standard input of the `steamcmd`
        service, so are executed exactly as if typed into the terminal. Do not
        add credentials here - the user will already be signed in by the time
        these commands run, and the game will already have been installed.

        To configure username and password, see `services.steamServers`.
      '';
      example = ''
        workshop_download_item 1308528328
      '';
    };

    startScript = mkOption {
      type = types.path;
      description = ''
        Script used to launch the server after all trivial installation/setup
        has occurred.

        This will be executed from within the game server's installation path
        (in `/var/lib/''${name}`). Game servers are often sensitive to the
        directory they are executed in, so make sure to `cd` into the location
        the server expects.

        The server binary will most likely need to be patched using `patchelf`
        before it can function. Also see the example.

        If additional credentials are required, expose these using
        `systemd.services.steamServers-''${name}.serviceConfig.LoadCredential`.
        See `man systemd.exec` for more information regarding systemd's
        credential system.
      '';
      example = ''
        cp ''${configuration} storage/starbound_server.config
        cd linux
        patchelf --set-interpreter ''${stdenv.cc.bintools.dynamicLinker} \
            ./starbound_server
        ./starbound_server
      '';
    };
  };
}
