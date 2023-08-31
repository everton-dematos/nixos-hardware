{
  pkgs, targetBoard, ...
}:

with pkgs; let
  payload-generator = pkgs.callPackage ./hss-payload-generator.nix {};
  #sel4 = pkgs.callPackage ./sel4.nix {};
  sel4_local = /home/ssrclab1/Documents/seL4/RISC-V/seL4_TEE_platsecdev_OS/build/images;
  payload_config = ./uboot.yaml;
in
buildUBoot rec {
  pname = "uboot";
  version = "linux4microchip+fpga-2023.06";

  src = fetchFromGitHub {
    owner = "polarfire-soc";
    repo = "u-boot";
    rev = "7e19f9dff788025403ac6a34d9acf8736eef32ff";
    sha256 = "sha256-1qmifjjNxPOUWRgZdQk6Ld5KGQk/PypSRK/ILPSsTLs";
  };

  extraMakeFlags = [
          "OPENSBI=${opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.bin"
  ];

  patches = [
    ./patches/0001-Boot-environment-for-Microchip-Iciclle-Kit.patch
    ./patches/0002-Riscv-Fix-build-against-binutils-2.38.patch
    ./patches/0003-Disable_cpu4.patch
    ./patches/0004-Memory_addr.patch
    ./patches/0005-Memory_SMODE.patch
    ./patches/0006-Memory_addr_defconfig.patch
  ];
  defconfig = "${targetBoard}_defconfig";
  enableParallelBuilding = true;
  extraMeta.platforms = ["riscv64-linux"];
  postBuild = ''
        cp ${sel4_local}/payload_seL4.bin .
        ${payload-generator}/hss-payload-generator -c ${payload_config} payload.bin
        '';
  filesToInstall = [ "payload_seL4.bin" ];
}
