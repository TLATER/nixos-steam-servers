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
      example = 211820;
    };

    steamUser = mkOption {
      type = types.str;
      description = ''
        Name of the steam user to be used for authentication.

        Defaults to `anonymous`. Only change this for servers which *require*
        sign-in.

        Note: If you do use your own account, you will likely need to
              disable steam guard to reasonably be able to use
              this. Valve, like most games companies, is *terrible* at
              security, especially if game server hosting is involved.
              Complaints should go to them.

              This module takes care not to write passwords in plain
              text anywhere they could become public on your system,
              however we do not control `steamcmd`, so we don't know
              if it may start logging or caching passwords at any
              point. To be on the safe side, treat the game's storage
              directory in `/var/lib/<name>` as if it contained your
              steam password in plain text.

              Some people recommend creating throwaway steam accounts
              for each game. This of course is better if you care
              about your account security, but it does require buying
              the games again - and would reward Valve specifically
              for being incompetent. Just use `anonymous` where
              possible and email Valve or join steam discussions if
              you are as annoyed as I am otherwise.

              Something like https://github.com/Weilbyte/steamcmd-2fa
              may be an option in the future.
      '';
      default = "anonymous";
    };

    steamUserPasswordFile = mkOption {
      type = types.path;
      description = ''
        Path to a file containing your steam password, used in
        conjunction with `steamUser`. Make sure you read its
        documentation too.

        Do *not* set this to a path created using `pkgs.writeText`, or
        a raw path read by nix (e.g. ./steam-password). Both will end
        up in the nix store and be world-readable.

        Instead, either copy the file to the correct location by hand
        once it's running, or use something like sops-nix to safely
        deploy it in an encrypted fashion.
      '';
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
        `systemd.services.update-''${name}.serviceConfig.LoadCredential`.
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
