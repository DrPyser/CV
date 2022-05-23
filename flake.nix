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
      # rubyenv = pkgs.ruby;
        #.withPackages (p: with p; [ jekyll ]);
      # tools = [ pkgs.glow rubyenv pkgs.bundix ];
      # bundlerenv = pkgs.bundlerEnv {
      #   ruby = rubyenv;
      #   name = "cv-github-pages";
      #   gemdir = ./.;
      # };
      # rubyenv = (import ./shell.nix {
      #   inherit self pkgs lib;
      #   inputs = buildInputs;
      # });
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
              # ./shell.nix
            ];
            packages = [
              # (import ./shell.nix {
              #   inherit self pkgs lib;
              #   inputs = buildInputs;
              # })

              # bundlerenv
              # bundlerenv.ruby
            ] ++ buildInputs;
            commands = [
              {
                package = pkgs.glow;
                help = "Render markdown files in terminal";
              }
            ];
          };
      });
}
