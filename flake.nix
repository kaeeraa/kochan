{
  description = "Kochan with poetry2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      poetry2nix,
      ...
    }:
    let
      pythonVer = "python312";
    in
    {
      overlay = final: prev: {

        kochan = final.poetry2nix.mkPoetryApplication {
          projectDir = self;
          preferWheels = true;
          python = final.${pythonVer};
        };

        kochanEnv = final.poetry2nix.mkPoetryEnv {
          projectDir = self;
          preferWheels = true;
          python = final.${pythonVer};
          editablePackageSources = {
            kochan = self;
          };
        };

        poetry = (prev.poetry.override { python = prev.${pythonVer}; });
      };
    }
    // (
      let

        forEachSystem =
          systems: func:
          nixpkgs.lib.genAttrs systems (
            system:
            func (
              import nixpkgs {
                inherit system;
                config.allowUnfree = true;
                overlays = [
                  poetry2nix.overlay
                  self.overlay
                ];
              }
            )
          );

        forAllSystems = func: (forEachSystem [ "x86_64-linux" "aarch64-darwin" ] func);

      in
      {
        devShells = forAllSystems (
          pkgs: with pkgs; {
            default = mkShellNoCC {
              packages = [
                kochanEnv
                poetry
              ];

              shellHook = ''
                export PYTHONPATH=${pkgs.${pythonVer}}
              '';
            };
          }
        );

        packages = forAllSystems (pkgs: {
          default = pkgs.kochan;

          poetry = pkgs.poetry;
        });

      }
    );
}
