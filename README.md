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

b.log
sake.log
krubb.log

max-width 640px
Menu anchered to left, otherwise top in tablet/mobile
