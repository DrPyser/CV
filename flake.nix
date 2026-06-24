{
  description = "Curriculum Vitae - charleslanglois.dev";

  inputs.nix-pandoc.url = "github:serokell/nix-pandoc";
  inputs.nix-pandoc.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nix-pandoc, nixpkgs }:
    let system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
        rubyenv = pkgs.bundlerEnv {
          ruby = pkgs.ruby_3_3;
          name = "CV-bundler-env";
          gemdir = ./.;
        };
        pandoc = pkgs.symlinkJoin {
          name = "pandoc-cv";
          paths = with pkgs; [ pandoc texlive.combined.scheme-small wkhtmltopdf ];
          meta.priority = 10;
        };
    in {
      packages.${system} = {
        inherit rubyenv;
        assets = pkgs.stdenv.mkDerivation {
          name = "cv.charleslanglois.dev";
          src = ./.;
          buildInputs = [ rubyenv rubyenv.wrappedRuby ];
          buildPhase = "bundle exec jekyll build";
          installPhase = ''
            mkdir -p $out
            cp -r _site/* $out/
          '';
        };
        pdf = nix-pandoc.mkDoc.${system} {
          name = "charles-langlois-cv";
          src = ./.;
          extraBuildInputs = [ pkgs.wkhtmltopdf ];
        };
        default = self.packages.${system}.assets;
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [ rubyenv rubyenv.wrappedRuby ];
      };
    };
}
