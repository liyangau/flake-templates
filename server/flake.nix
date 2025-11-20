{
  description = "Manage NixOS server remotely";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    colmena.url = "github:zhaofengli/colmena";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      disko,
      colmena,
      nixos-generators,
      ...
    }:
    {
      nixosConfigurations.demo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
        ];
      };

      packages.x86_64-linux = {
        lxc = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./configuration.nix
          ];
          format = "proxmox-lxc";
        };
      };

      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
        defaults =
          { pkgs, ... }:
          {
            environment.systemPackages = [
              pkgs.curl
            ];
          };
        demo =
          { pkgs, ... }:
          {
            deployment = {
              targetHost = "demo";
              targetPort = 22;
              targetUser = "fomm";
              buildOnTarget = true;
              tags = [ "homelab" ];
            };
            nixpkgs.system = "x86_64-linux";
            imports = [
              disko.nixosModules.disko
              ./configuration.nix
            ];
            time.timeZone = "Australia/Melbourne";
          };
      };
    };
}
