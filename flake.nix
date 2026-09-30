{
  description = "Tagref helps you manage cross-references in your code. You can use it to help keep things in sync, document assumptions, maintain invariants, etc.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          lib,
          pkgs,
          self',
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            inputsFrom = [
              self'.packages.default
              pkgs.clippy
              pkgs.rust-analyzer
              pkgs.rustfmt
            ];
          };

          packages.default = pkgs.rustPlatform.buildRustPackage (
            finalAttrs:
            let
              cargoTomlManifest = with builtins; fromTOML (readFile ./Cargo.toml);
              inherit (cargoTomlManifest.package) description homepage version;
            in
            {
              pname = "tagref";
              inherit version;

              src = lib.cleanSource ./.;

              cargoLock.lockFile = ./Cargo.lock;

              meta = {
                inherit description homepage;
                license = lib.licenses.mit;
                mainProgram = "tagref";
              };
            }
          );
        };
    };
}
