{ pkgs, ...}:
with pkgs;
stdenv.mkDerivation rec {
  pname = "sel4";
  version = "v2023.08";

  src = fetchFromGitHub {
    owner = "tiiuae";
    repo = "optee_seL4";
    rev = "platsec_dev";
    sha256 = "";
  };

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  nativeBuildInputs = [ cmake ninja ];

  buildPhase = ''
    runHook preBuild

    repo init -u git@github.com:tiiuae/optee_manifest -m seL4_TEE.xml
    repo sync

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
