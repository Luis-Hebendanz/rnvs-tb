{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
      myapp = forAllSystems (system: pkgs.${system}.poetry2nix.mkPoetryApplication { projectDir = self; });
    in
    rec {
      packages = forAllSystems (system: {
        default =
          let
            spkgs = pkgs.${system};
            pypkgs = pkgs.${system}.python310Packages;
          in
          pypkgs.buildPythonPackage {
            pname = "rnvs-tb";
            version = "2022-projekt2-1";
            src = self;

            doCheck = false;
            propagatedBuildInputs = [ spkgs.lsof pypkgs.docker ];
            buildInputs =  with pypkgs; [ setuptools ];
          };
      });



      devShells = forAllSystems (system: {
        default =
          let
            spkgs = pkgs.${system};
            pypkgs = pkgs.${system}.python310Packages;
          in
          pkgs.${system}.mkShellNoCC {
          packages = with spkgs; [

          ];
        };
      });
    };
}
