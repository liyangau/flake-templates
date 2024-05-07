{
  inputs = {
    systems.url = "systems";
    nixpkgs.url = "nixpkgs";
    nur.url = "nur";
  };

  outputs =
  {
    self,
    nixpkgs,
    systems,
    nur,
  }:
  let
    forEachSystem =
      f:
      nixpkgs.lib.genAttrs (import systems) (
        system:
        f {
          pkgs = import nixpkgs {
            overlays = [ nur.overlay ];
            inherit system;
          };
        }
      );
  in
  {
    devShells = forEachSystem (
      { pkgs }: {
        default = pkgs.mkShellNoCC {
          packages = [
            pkgs.nur.repos.liyangau.squoosh-cli
          ];
        };
      }
    );
  };
}
