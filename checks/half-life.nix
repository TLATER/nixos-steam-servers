{nixosTest}:
nixosTest {
  name = "half-life";
  nodes.server = {...}: {
    imports = [
      ../modules
    ];

    services.steam-servers.servers.half-life = {
      appId = 90;
    };
  };
  testScript = ''
    machine.start()
    machine.systemctl("start update-half-life.service")
    machine.wait_for_unit("update-half-life.service")
    machine.succeed("ls -l /var/lib/half-life/")
  '';

  # TODO(tlater): Make the test actually succeed
  #
  # server # [    4.566162] systemd[793]: update-half-life.service: Failed to locate executable /nix/store/m5a9gnikhl8qfn2l60s44d65ilc7420w-source/scripts/update-server.sh: No such file or directory
  # server # [    4.567096] systemd[793]: update-half-life.service: Failed at step EXEC spawning /nix/store/m5a9gnikhl8qfn2l60s44d65ilc7420w-source/scripts/update-server.sh: No such file or directory
}
