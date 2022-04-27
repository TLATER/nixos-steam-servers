{pkgs}: let
  inherit (pkgs) callPackage;
in {
  test-half-life = callPackage ./half-life.nix {};
}
