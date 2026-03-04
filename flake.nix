{
  description = "Personal website built with Hakyll and Tailwind";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        hpkgs = pkgs.haskellPackages;

        # The Hakyll site generator binary
        generator = hpkgs.developPackage { root = ./.; };

        # The fully built static site
        website = pkgs.stdenv.mkDerivation {
          name = "website";
          src = ./.;
          nativeBuildInputs = [ generator pkgs.tailwindcss ];
          buildPhase = ''
            tailwindcss -i css/input.css -o css/style.css --minify
            site build
          '';
          installPhase = ''
            cp -r _site $out
          '';
        };
      in
      {
        packages = {
          default = website;
          inherit generator;
        };

        devShells.default = hpkgs.developPackage {
          root = ./.;
          returnShellEnv = true;
          modifier = drv:
            pkgs.haskell.lib.addBuildTools drv [
              hpkgs.cabal-install
              hpkgs.haskell-language-server
              pkgs.tailwindcss_4
              pkgs.imagemagick
            ];
        };
      });
}
