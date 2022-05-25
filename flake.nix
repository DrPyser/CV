{
  description = "A very basic flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.devshell.url = "github:numtide/devshell";

  outputs = { self, flake-utils, devshell, nixpkgs }:
    let
      lib = nixpkgs.lib // flake-utils.lib // devshell.lib;
      supportedSystems = [ lib.system.x86_64-linux ];
    in lib.eachSystem supportedSystems (system:
      let pkgs = import nixpkgs {
        inherit system;
        overlays = [ devshell.overlay ];
      };
      rubyenv = pkgs.bundlerEnv {
          ruby = pkgs.ruby_3_1;
          name = "CV-bundler-env";
          gemfile  = ./Gemfile;
          lockfile = ./Gemfile.lock;
          gemset   = ./gemset.nix;
        };

      buildInputs = with pkgs; [
        glow
        bundix
        rubyenv
      ];
      pandoc = pkgs.symlinkJoin {
        name = "pandoc-cv";
        paths = [pkgs.pandoc pkgs.texlive.combined.scheme-small pkgs.wkhtmltopdf pkgs.zathura ];
        # prevent conflicts with existing packages in env
        meta.priority = 10;
      };
      in {
        packages = rec {
          inherit rubyenv;
          assets = null;
          pdf = null;
          default = self.packages.${system}.assets;
        };
        # test environments
        # nixosConfigurations = [
        # ];
        # dev environment
        devShells.rubyenv = pkgs.devshell.mkShell {
          packages = [
            rubyenv
            rubyenv.wrappedRuby
          ];

        };
        devShell =
          pkgs.devshell.mkShell {
            imports = [
            ];
            packages = [
            ] ++ buildInputs;
            commands = [
              {
                package = pkgs.glow;
                help = "Render markdown files in terminal";
              }
              {
                package = pandoc;
                help = "convert markdown sources to other formats(e.g. pdf)";
              }
            ];
          };
      });
}
