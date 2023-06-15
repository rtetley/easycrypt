{
  description = "EasyCrypt";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      {
        packages =
          with import nixpkgs { inherit system; };
          easycrypt;
        
        defaultPackage = self.packages.${system};

        devShells.default =
          with import nixpkgs { inherit system; };
          mkShell {
            buildInputs = [ git ] ++ (with ocamlPackages; [
                ocaml
                findlib
                batteries
                camlp-streams
                dune_3
                dune-build-info
                dune-site
                inifiles
                menhir
                menhirLib
                merlin
                yojson
                why3
                zarith
                ocaml-lsp
            ]);
          };

      }
    );
}