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
    }@inputs:
    let
      pythonVer = "python312";
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forEachSystem =
        systems: func:
        nixpkgs.lib.genAttrs systems (
          system:
          func (
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [
                poetry2nix.overlays.default
                self.overlay
              ];
            }
          )
        );

      forAllSystems = forEachSystem systems;

    in
    {
      overlay = final: prev: {
        kochan = final.poetry2nix.mkPoetryApplication {
          projectDir = self;
          preferWheels = true;
          python = final.${pythonVer};

          preBuild = ''
            cp ${self}/build.py ./build.py
          '';

          overrides = final.poetry2nix.overrides.withDefaults (
            self: super: {
              kochan = super.kochan.overridePythonAttrs (old: {
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
                  final.cython
                  final.gcc
                  final.pkg-config
                  final.python312Packages.poetry-core
                  final.python312Packages.setuptools
                ];
                CYTHON_INCLUDE_DIRS = "${final.${pythonVer}}/include/python3.12";
                buildInputs = (old.buildInputs or [ ]) ++ [ final.glibc ];
              });
            }
          );
        };

        kochanEnv = final.poetry2nix.mkPoetryEnv {
          projectDir = self;
          python = final.${pythonVer};
          editablePackageSources = {
            kochan = self;
          };
          preferWheels = true;
        };

        poetry = prev.poetry.override { python3 = prev.${pythonVer}; };
      };

      packages = forAllSystems (pkgs: {
        default = pkgs.kochan;
        inherit (pkgs) poetry;
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            kochanEnv
            poetry
            python312Packages.cython
            gcc
            pkg-config
            python312Packages.setuptools
            python312Packages.pip
          ];

          shellHook = ''
            export PYTHONPATH="${pkgs.kochanEnv}/${pkgs.${pythonVer}.sitePackages}:$PYTHONPATH"
            export LD_LIBRARY_PATH="${pkgs.glibc}/lib:${pkgs.stdenv.cc.cc.lib}/lib"
            echo "Development environment ready!"
          '';
        };
      });
    };
}
