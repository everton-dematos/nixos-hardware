{ pkgs, ...}:
with pkgs;
stdenv.mkDerivation rec {
  pname = "sel4";
  version = "v2023.08";

  src = fetchFromGitHub {
    owner = "tiiuae";
    repo = "optee_manifest";
    rev = "83f8c86a6aa0488f1feb340ffa9fefd0479cd457";
    sha256 = "";
  };

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  nativeBuildInputs = [ cmake ninja ];

  buildPhase = ''
    runHook preBuild

    cmake -G Ninja ../projects/sel4_teeos

    ninja
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp ./build/images/teeos_root-image-riscv-polarfire $out

    runHook postConfigure
  '';
}
