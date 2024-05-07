{
  inputs = {
    systems.url = "systems";
    nixpkgs.url = "nixpkgs";
  };

  outputs =
  {
    self,
    nixpkgs,
    systems,
  }:
  let
    forEachSystem =
      f: nixpkgs.lib.genAttrs (import systems) (system: f { pkgs = import nixpkgs { inherit system; }; });
  in
  {
    devShells = forEachSystem (
      { pkgs }:
      {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            (callPackage ./default.nix {})
          ];
        };
      }
    );
  };
}