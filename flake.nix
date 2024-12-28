{
  description = "My personal website";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs?ref=23.11"; };

  outputs = { nixpkgs, systems, ... }:
    let
      eachSystem = with nixpkgs.lib;
        f:
        foldAttrs mergeAttrs { }
        (map (s: mapAttrs (_: v: { ${s} = v; }) (f s)) (import systems));
    in eachSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # Lamdera
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs

            # Dev
            nil
            nixfmt
            nixd

            # Elm
            elmPackages.elm
            elmPackages.elm-language-server
            elmPackages.elm-pages
            elmPackages.elm-format
            elmPackages.elm-review
            elmPackages.elm-test
          ];
        };
        # FIXME: Seems like the elm-pages script relies on $HOME. This needs to be fixed in elm-pages.
        # packages.default = pkgs.stdenv.mkDerivation {
        #   name = "website";
        #   src = ./.;
        #   nativeBuildInputs = [
        #     pkgs.elmPackages.elm-pages
        #     pkgs.elmPackages.elm-format
        #     pkgs.elmPackages.lamdera
        #   ];
        #   buildPhase = ''
        #     ${pkgs.elmPackages.elm-pages}/bin/elm-pages build --base $out
        #   '';
        #   installPhase = ''
        #     mkdir $out
        #     cp -r ./dist $out
        #   '';
        # };
        checks = {
          format = pkgs.runCommand "format" {
            buildInputs = [ pkgs.elmPackages.elm-format ];
          } ''
            ${pkgs.elmPackages.elm-format}/bin/elm-format --validate ${./.}
            touch $out
          '';

          # review = pkgs.runCommand "review" {
          #   buildInputs = [
          #     pkgs.elmPackages.elm-review
          #   ];
          # } ''
          #   ${pkgs.elmPackages.elm-review}/bin/elm-review ${./.}
          #   touch $out
          # '';
        };
      });
}
