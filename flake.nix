{
  description = "Manage steam game servers with nix!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }: let
    inherit (flake-utils.lib) eachSystem defaultSystems;
  in
    {
      nixosModules.default = import ./modules;
    }
    // (eachSystem defaultSystems) (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          rnix-lsp
        ];
        shellHook = ''

        '';
      };
    });
}
