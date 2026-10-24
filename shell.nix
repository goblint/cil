{ pkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  }) {}
}:

pkgs.mkShell {
  dontDetectOcamlConflicts = true;
  nativeBuildInputs = with pkgs.ocamlPackages; [
    cppo
    dune-configurator
    dune_3
    findlib
    ocaml
    odoc
    ppx_deriving_yojson
  ];
  buildInputs = with pkgs.ocamlPackages; [
    zarith
  ];
}
