{
  description = "Manage steam game servers with nix!";

  # Only used for testing/dev shells
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    alejandra = {
      url = "github:kamadorueda/alejandra/1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    alejandra,
    nixpkgs,
    ...
  }: let
    # steamcmd only supports x86_64-linux (and in theory Windows, but
    # this flake is only concerned with NixOS), and the game servers
    # themselves likely do the same.
    #
    # It may be possible to run this stuff with something like 86box
    # or something like that, but if you're doing anything like that
    # you're on your own.
    #
    # Do share if you're successful though!
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosModules.default = import ./modules;

    checks.${system} = import ./checks {inherit pkgs;};

    # In theory, we should use flake-utils to define this for more
    # than just x86. In practice, I'm lazy, and I don't think anyone
    # will be developing on non-x86.
    #
    # Tell me if this annoys you.
    devShell.${system} = pkgs.mkShell {
      buildInputs = with pkgs; [
        alejandra.packages.${system}.default
        rnix-lsp
      ];
    };
  };
}
