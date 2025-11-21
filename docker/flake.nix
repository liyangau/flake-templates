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
      ];
      forEachSupportedSystem =
        f:
        lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
      imageName = "example";
      imageTag = "latest";
      mkDockerImage =
        pkgs: targetSystem:
        let
          archSuffix = if targetSystem == "x86_64-linux" then "amd64" else "arm64";
        in
        pkgs.dockerTools.buildImage {
          name = imageName;
          tag = "${imageTag}-${archSuffix}";
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = [ pkgs.bashInteractive ];
            pathsToLink = [ "/bin" ];
          };
        };
    in
    {
      packages = forEachSupportedSystem (
        { system, pkgs }:
        let
          buildForLinux =
            targetSystem:
            if system == targetSystem then
              mkDockerImage pkgs targetSystem
            else
              mkDockerImage (import nixpkgs {
                localSystem = system;
                crossSystem = targetSystem;
              }) targetSystem;
        in
        {
          "amd64" = buildForLinux "x86_64-linux";
          "arm64" = buildForLinux "aarch64-linux";
        }
      );

      apps = forEachSupportedSystem (
        { system, pkgs }:
        {
          default = {
            type = "app";
            program = toString (
              pkgs.writeScript "build-multi-arch" ''
                #!${pkgs.bash}/bin/bash
                set -e
                echo "Building x86_64-linux image..."
                nix build .#amd64 --out-link result-${system}-amd64
                echo "Building aarch64-linux image..."
                nix build .#arm64 --out-link result-${system}-arm64
              ''
            );
          };
        }
      );
    };
}
