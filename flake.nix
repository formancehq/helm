{
  description = "Wallets dev env";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

    go-tooling = {
      url = "github:NixOS/nixpkgs/8cec5ef1131078ea76689e84c362b0ed6a1fb6a1";
      flake = false;
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur, go-tooling }:
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
          go = prev.callPackage "${go-tooling}/pkgs/development/compilers/go/1.27.nix" {
            buildGo127Module = buildGoModule;
          };
          buildGoModule = prev.buildGoModule.override { inherit go; };
          go127 = prev.callPackage "${go-tooling}/pkgs/development/compilers/go/1.27.nix" {
            buildGo127Module = buildGo127Module;
          };
          buildGo127Module = prev.buildGoModule.override { go = go127; };
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
