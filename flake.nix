{
  description = "Wallets dev env";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

    # Published stable Go compiler and matching module builder only.
    nixpkgs-go-stable = {
      url = "https://api.flakehub.com/f/pinned/NixOS/nixpkgs/0.2605.1016949%2Brev-1f607aa79b6356ed45d3cd3c8079c196e79efa2c/01a17424-ae2d-7b20-83c4-cf14527294c3/source.tar.gz";
      flake = false;
    };

    # Retain golangci-lint 2.15.0; stable currently provides 2.12.2.
    go-tooling = {
      url = "github:NixOS/nixpkgs/8cec5ef1131078ea76689e84c362b0ed6a1fb6a1";
      flake = false;
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur, nixpkgs-go-stable, go-tooling }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forEachSupportedSystem = f:
        nixpkgs.lib.genAttrs supportedSystems (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default nur.overlays.default ];
              config.allowUnfree = true;
            };
          in
          f { pkgs = pkgs; system = system; }
        );

    in
    {
      overlays.default = final: prev:
        let
          goPkgs = import nixpkgs-go-stable { system = prev.stdenv.hostPlatform.system; };
          go = goPkgs.go_1_27;
          buildGoModule = goPkgs.buildGo127Module;
          buildGo127Module = goPkgs.buildGo127Module;
        in
        {
          inherit go;
          mockgen = prev.mockgen.override { inherit buildGoModule; };
          golangci-lint = prev.callPackage "${go-tooling}/pkgs/by-name/go/golangci-lint/package.nix" {
            inherit buildGo127Module;
          };
        };

      devShells = forEachSupportedSystem ({ pkgs, system }:
        {
          default = pkgs.mkShell {
            GOTOOLCHAIN = "local";
            packages = with pkgs; [
              go
              gotools
              golangci-lint
              ginkgo
              pkgs.nur.repos.goreleaser.goreleaser-pro
              just
              kubernetes-helm
              kustomize_4
              mockgen
              yq
            ];
          };
        }
      );
    };
}
