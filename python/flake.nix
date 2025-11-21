{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSystem =
        f:
        lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      devShells = forEachSystem (
        { pkgs, ... }:
        {
          default =
            let
              python = pkgs.python312;
            in
            pkgs.mkShellNoCC {
              packages = [
                pkgs.hello
                (python.withPackages (ps: [
                  ps.jwcrypto
                ]))
              ];
            };
        }
      );
    };
}
