{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    nixpkgs,
    systems,
    ...
  }: let
    eachSystem = nixpkgs.lib.genAttrs (import systems);
    nixpkgsFor = system:
      import nixpkgs {
        inherit system;

        overlays = [
          (final: prev: {
            # as of nixpkgs/nixpkgs-unstable@8bc6cf8907b5f38851c7c0a7599bfa2ccf0a29eb (14-04-2025),
            # bun is still at v1.2.8 and we need v1.2.9 for `S3Client.list`.
            bun = let
              inherit (prev) fetchurl stdenvNoCC;

              version = "1.2.9";
              sources = {
                aarch64-darwin = fetchurl {
                  url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-aarch64.zip";
                  hash = "sha256-valv+2j45f0W0rNEMiWuXibI2+eQy7Nd26Jht74oBhg=";
                };

                aarch64-linux = fetchurl {
                  url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-aarch64.zip";
                  hash = "sha256-oqtdrUAxo7RdNzomfL0FE+c+m1TOsNu5tF1veHZ/aac=";
                };

                x86_64-darwin = fetchurl {
                  url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-darwin-x64-baseline.zip";
                  hash = "sha256-XP9phMQsYMHy9oIbOchsAVLj4UMnUFRGNt2JoPardZY=";
                };

                x86_64-linux = fetchurl {
                  url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/bun-linux-x64.zip";
                  hash = "sha256-LAjGN0h8YcN38pmlkZ6P9Pyghbqa/obOE9Wy93mb82s=";
                };
              };
            in
              prev.bun.overrideAttrs (old: {
                inherit version;

                src = sources.${stdenvNoCC.hostPlatform.system} or (throw "unsupported system: ${stdenvNoCC.hostPlatform.system}");
              });
          })
        ];
      };
  in {
    formatter = eachSystem (system: (nixpkgsFor system).alejandra);
    devShells = eachSystem (system: let
      pkgs = nixpkgsFor system;
    in {
      default = pkgs.mkShell { buildInputs = [pkgs.bun]; };
    });
  };
}
