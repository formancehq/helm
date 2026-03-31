{
  description = "Wallets dev env";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    just-lib = { url = "git+ssh://git@github.com/formancehq/just-lib"; flake = false; };
  };

  outputs = { self, nixpkgs, nur, just-lib }:
    let
      goVersion = 23;

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
      overlays.default = final: prev: {
        go = final."go_1_${toString goVersion}";
      };

      devShells = forEachSupportedSystem ({ pkgs, system }:
        {
          default = pkgs.mkShell {
            shellHook = ''
              ln -sfn ${just-lib} .just-lib
            '';
            packages = with pkgs; [
              go
              gotools
              golangci-lint
              ginkgo
              pkgs.nur.repos.goreleaser.goreleaser-pro
              just
              kustomize_4
              mockgen
              yq
            ]
            ++ (import "${just-lib}/helm/pkgs.nix" { inherit pkgs; });
          };
        }
      );
    };
}