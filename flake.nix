{
  description = "Demo for purga cli tool";
  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
      flake-utils.url = "github:numtide/flake-utils";
      purgaArgs = {
        url = "file+file:///dev/null";
        flake = false;
      };
    };

  outputs = { self, nixpkgs, flake-utils, purgaArgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;

        args = lib.trivial.importJSON purgaArgs.outPath;

        showArgs =
          let
            argsList = lib.attrsets.mapAttrsToList
              (name: value: ''
                echo 'name = ${name}, value = ${value}'
              '')
              args;
          in
          lib.concatStringsSep "\n" argsList;

        purgaDemo = pkgs.stdenv.mkDerivation {
          name = "purgaDemo";
          src = null;

          buildCommand = ''
            mkdir -p $out/bin
            echo "#!/bin/sh" > $out/bin/purgaDemo
            cat<<EOF > $out/bin/purgaDemo
            ${showArgs}
            EOF
            chmod +x $out/bin/purgaDemo
          '';
        };


      in
      {
        apps.default = {
          type = "app";
          program = "${purgaDemo}/bin/purgaDemo";
        };
      }
    );
}
