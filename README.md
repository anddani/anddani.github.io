# Website

Build pipeline:
  1. tailwindcss -i css/input.css -o css/style.css --minify
  2. site build

Dev workflow:
```sh
nix develop
cabal run site -- watch
# in another terminal:
tailwindcss -i css/input.css -o css/style.css --watch
```

The odin-gb page needs the emulator's web build next to it. Locally:
```sh
install -m 644 $(nix build github:anddani/odin-gb#web --no-link --print-out-paths)/{odin-gb.js,odin-gb.wasm,odin.js,audio-worklet.js} odin-gb/
```

Generate thumbnails:
```sh
cabal run make-thumbnails -- --force
```

