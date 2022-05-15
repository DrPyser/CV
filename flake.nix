{
  description = "A very basic flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.devshell.url = "github:numtide/devshell";

  outputs = { self, flake-utils, devshell, nixpkgs }:
    let
      lib = nixpkgs.lib // flake-utils.lib;
      supportedSystems = [ lib.system.x86_64-linux ];
    in lib.eachSystem supportedSystems (system:
      let pkgs = import nixpkgs {
        inherit system;
        overlays = [ devshell.overlay ];
      };
      tools = [ pkgs.glow ];
      in {
        devShell =
          pkgs.devshell.mkShell {
            imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
            packages = [

            ] ++ tools;
            commands = [
              {
                package = pkgs.glow;
                help = "Render markdown files in terminal";
              }
            ];
          };
      });
}
