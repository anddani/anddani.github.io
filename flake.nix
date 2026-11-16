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

        # Pre-fetched Elm dependencies for the nelm app, so `elm make`
        # works inside the network-less build sandbox. Regenerate
        # nelm/elm-srcs.nix and nelm/registry.dat with elm2nix after
        # changing nelm/elm.json.
        elmDeps = pkgs.elmPackages.fetchElmDeps {
          elmPackages = import ./nelm/elm-srcs.nix;
          elmVersion = "0.19.1";
          registryDat = ./nelm/registry.dat;
        };

        # The fully built static site
        website = pkgs.stdenv.mkDerivation {
          name = "website";
          src = ./.;
          nativeBuildInputs = [ generator pkgs.tailwindcss_4 pkgs.elmPackages.elm ];
          LANG = "C.UTF-8";
          LC_ALL = "C.UTF-8";
          configurePhase = elmDeps;
          buildPhase = ''
            tailwindcss -i css/input.css -o css/style.css --minify
            (cd nelm && elm make src/Main.elm --optimize --output=main.js)
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
              pkgs.elmPackages.elm
              pkgs.elmPackages.elm-format
              pkgs.elm2nix
            ];
        };
      });
}
