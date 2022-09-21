
{ config, pkgs, ... }:

{
  networking.hostId = "9d3d7939";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.zfsSupport = true;
  boot.loader.grub.enableCryptodisk = true;
  boot.loader.grub.extraPrepareConfig = ''
    mkdir -p /boot/efis
    for i in  /boot/efis/*; do mount  ; done
  
    mkdir -p /boot/efi
    mount /boot/efi
  '';
  boot.loader.grub.extraInstallCommands = ''
  ESP_MIRROR=/tmp/tmp.xuuAlZGnYA
  cp -r /boot/efi/EFI 
  for i in /boot/efis/*; do
   cp -r /EFI 
  done
  rm -rf 
  '';
  boot.loader.grub.devices = [
    "/dev/disk/by-id/nvme-INTEL_SSDPEKNW512G8_BTNH94660R3N512A"
  ];
  users.users.root.initialHashedPassword = "$6$FbkMV9EQmXrWCzeS$U4si.o/2WCtUtfn5ANf1h0yqPzsje4LJjEhyGauGDvj6LO1D7CnwZs4WYLxSj6PcoCYhXSbVeZ4MAKDR59K2.1";
}
