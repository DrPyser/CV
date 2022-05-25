with (import <nixpkgs> {});
let
  env = bundlerEnv {
    name = "CV-bundler-env";
    inherit ruby_3_1;
    gemfile  = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset   = ./gemset.nix;
  };
in stdenv.mkDerivation {
  name = "CV";
  buildInputs = [ env ];
}
