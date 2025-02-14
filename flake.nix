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

      mkPackage = final: {
        kochan = final.poetry2nix.mkPoetryApplication {
          projectDir = self;
          preferWheels = true;
          python = final.${pythonVer};

          overrides = final.poetry2nix.overrides.withDefaults (
            self: super: {
              kochan = super.kochan.overridePythonAttrs (old: {
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
                  final.cython
                  final.gcc
                  final.pkg-config
                ];
                propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [
                  final.python312Packages.gunicorn
                ];
              });
            }
          );

          postInstall = ''
            mkdir -p $out/bin
            cat <<EOF > $out/bin/kochan-server
            #!${final.bash}/bin/bash
            exec ${final.python312Packages.gunicorn}/bin/gunicorn \\
              --workers 4 \\
              --timeout 120 \\
              --bind "0.0.0.0:8710" \\
              "kochan.wsgi:app"
            EOF
            chmod +x $out/bin/kochan-server
          '';
        };
      };

    in
    {
      overlay = final: prev: {
        kochan = (mkPackage final).kochan;
        poetry = prev.poetry.override { python3 = prev.${pythonVer}; };
      };

      packages = forAllSystems (pkgs: {
        default = pkgs.kochan;
        inherit (pkgs) poetry;
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            poetry
            python312Packages.cython
            gcc
            pkg-config
            python312Packages.gunicorn
          ];

          shellHook = ''
            export PYTHONPATH="$PWD/src:$PYTHONPATH"
            echo "Development environment ready!"
          '';
        };
      });
    };
}
