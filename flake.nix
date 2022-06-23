{
  description = "A very basic flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.nix-pandoc.url = "github:serokell/nix-pandoc";
  inputs.nix-pandoc.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, flake-utils, devshell, nix-pandoc, nixpkgs }:
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
        # glow
        bundix
        rubyenv
        (lib.meta.lowPrio rubyenv.wrappedRuby)
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
          assets = pkgs.stdenv.mkDerivation {
            inherit buildInputs;
            name = "cv.charleslanglois.dev";
            phases = [ "unpackPhase" "buildPhase" "installPhase" ];
            buildPhase = "jekyll build";
          };
          pdf = nix-pandoc.mkDoc.${system} {
            name = "charles-langlois-cv";
            src = ./.;
            extraBuildInputs = [pkgs.wkhtmltopdf];
          };
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
                name = "pandoc";
                help = "convert markdown sources to other formats(e.g. pdf)";
              }
            ];
          };
      });
}
