#!/usr/bin/env bash
#
# Time script with
# (time bash zfs.sh) 2> log
#
# Run this script inside `sudo -i`
# https://openzfs.github.io/openzfs-docs
DEVICE="framework-12th-gen-intel"
# find disk by `ls /dev/disk/by-id/*`
DISK="/dev/disk/by-id/nvme-INTEL_SSDPEKNW512G8_BTNH94660R3N512A"
#DISK="/dev/disk/by-id/nvme-INTEL_SSDPEKNW512G8_BTNH94660R3N512A /dev/disk/by-id/nvme-INTEL_SSDPEKNW512G8_BTNH94660R3N512N"
#USB="L"
INST_PARTSIZE_SWAP=16

## Configure zfs.nix
### Set root password:
echo "Set root password"
rootPwd=$(mkpasswd -m SHA-512 -s)

### Configure hostid:
### Configure bootloader for both legacy boot and UEFI boot and mirror bootloader:
echo "" > zfs.nix
tee -a zfs.nix <<EOF
{ config, pkgs, ... }:

{
  networking.hostId = "$(head -c 8 /etc/machine-id)";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.initrd.luks.devices = {
EOF

for i in $DISK; do
  printf "    $(printf "${i##*/}-crypt") = {\n" | tee -a zfs.nix
  printf "      device = \"$(printf "${i}-part3")\";\n" | tee -a zfs.nix
  printf "      preLVM = true;\n" | tee -a zfs.nix
  printf "    };\n" | tee -a zfs.nix
done

tee -a zfs.nix <<EOF 
    # preLVM is required even if we're not using LVM
  };
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
    for i in  /boot/efis/*; do mount $i ; done
  
    mkdir -p /boot/efi
    mount /boot/efi
  '';
  boot.loader.grub.extraInstallCommands = ''
  ESP_MIRROR=$(mktemp -d)
  cp -r /boot/efi/EFI $ESP_MIRROR
  for i in /boot/efis/*; do
   cp -r $ESP_MIRROR/EFI $i
  done
  rm -rf $ESP_MIRROR
  '';
  boot.loader.grub.devices = [
EOF

for i in $DISK; do
  printf "    \"$i\"\n" | tee -a zfs.nix
done

tee -a zfs.nix <<EOF
  ];
  users.users.root.initialHashedPassword = "${rootPwd}";
}
EOF

## Configure disks:
### Partition the disks:
for i in ${DISK}; do

sgdisk --zap-all $i

sgdisk -n1:1M:+512M -t1:EF00 $i

sgdisk -n2:0:+4G -t2:BE00 $i

test -z $INST_PARTSIZE_SWAP || sgdisk -n4:0:+${INST_PARTSIZE_SWAP}G -t4:8200 $i

if test -z $INST_PARTSIZE_RPOOL; then
    sgdisk -n3:0:0   -t3:BF00 $i
else
    sgdisk -n3:0:+${INST_PARTSIZE_RPOOL}G -t3:BF00 $i
fi

sgdisk -a1 -n5:24K:+1000K -t5:EF02 $i
done

### Create boot pool:
zpool create \
    -o compatibility=grub2 \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=lz4 \
    -O devices=off \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/boot \
    -R /mnt \
    bpool \
   $(for i in ${DISK}; do
      printf "$i-part2 ";
      #${i}-part2; wrong. printf needs spacing for separation
     done) -f
#mirror \

### Encrypt with LUKS:
# https://blog.lazkani.io/posts/nixos-on-encrypted-zfs/
for i in ${DISK}; do
echo "Long PW"
cryptsetup --batch-mode luksFormat ${i}-part3
#cryptsetup luksFormat $(printf "$i-part3")
echo "Check long PW"
cryptsetup open --type luks ${i}-part3 ${i##*/}-crypt
#cryptsetup open --type luks $(printf "$i-part3") crypt
done
echo "Check Finished"

### Create root pool:
zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -R /mnt \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/ \
    rpool \
   $(for i in ${DISK}; do
      printf "/dev/mapper/${i##*/}-crypt ";
     done) -f
   #$(for i in ${DISK}; do
   #   printf "$i-part3 ";
   #  done)
#mirror \

### Create root system container encrypting with native ZFS:
#Unencrypted:

#sudo zfs create \
# -o canmount=off \
# -o mountpoint=none \
# rpool/nixos

#Encrypted:
echo "Short PW"
zfs create \
 -o canmount=off \
 -o mountpoint=none \
 -o encryption=on \
 -o keylocation=prompt \
 -o keyformat=passphrase \
 rpool/nixos

zfs create -o canmount=on -o mountpoint=/     rpool/nixos/root
zfs create -o canmount=on -o mountpoint=/home rpool/nixos/home
zfs create -o canmount=off -o mountpoint=/var  rpool/nixos/var
zfs create -o canmount=on  rpool/nixos/var/lib
zfs create -o canmount=on  rpool/nixos/var/log

zfs create -o canmount=off -o mountpoint=none bpool/nixos
zfs create -o canmount=on -o mountpoint=/boot bpool/nixos/root

### Format and mount ESP:

for i in ${DISK}; do
 mkfs.vfat -n EFI ${i}-part1
 mkdir -p /mnt/boot/efis/${i##*/}-part1
 mount -t vfat ${i}-part1 /mnt/boot/efis/${i##*/}-part1
done

mkdir -p /mnt/boot/efi
mount -t vfat $(echo $DISK | cut -f1 -d\ )-part1 /mnt/boot/efi



### Disable cache, stale cache will prevent system from booting:

mkdir -p /mnt/etc/zfs/
rm -f /mnt/etc/zfs/zpool.cache
touch /mnt/etc/zfs/zpool.cache
chmod a-w /mnt/etc/zfs/zpool.cache
chattr +i /mnt/etc/zfs/zpool.cache

### Generate and fix initial system configuration:

cp -r ../../../ssh /root/.ssh
chmod -R 700 /root/.ssh
eval "$(ssh-agent -s)"
ssh-add /root/.ssh/id_ed25519
git config --global user.email "bboxone@gmail.com"   
git config --global user.name "Suwon Park"

# need later than 22.11
# nix-2.11.0
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs
nix-channel --update
nix-env -iA nixpkgs.nix nixpkgs.cacert

nixos-generate-config --root /mnt

sed -i "/.\/hardware-configuration.nix/d" /mnt/etc/nixos/configuration.nix
#sed -i "s|\[ (modulesPath|\[ ./zfs.nix (modulesPath|g" /mnt/etc/nixos/hardware-configuration.nix
#sed -i "s|./hardware-configuration.nix|./hardware-configuration.nix ./zfs.nix|g" /mnt/etc/nixos/configuration.nix

sed -i '/boot.loader/d' /mnt/etc/nixos/configuration.nix
sed -i '/services.xserver/d' /mnt/etc/nixos/configuration.nix
sed -i '/system.stateVersion/d' /mnt/etc/nixos/configuration.nix

### Mount datasets with zfsutil option:
sed -i 's|fsType = "zfs";|fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];|g' \
/mnt/etc/nixos/hardware-configuration.nix

### Copy and git final configurations:
cp /mnt/etc/nixos/hardware-configuration.nix .
cp /mnt/etc/nixos/configuration.nix .
git add configuration.nix
git add hardware-configuration.nix
git add zfs.nix

### Install system and apply configuration:
nixos-install -v --show-trace --no-root-passwd  --root /mnt --flake ../..#$DEVICE

git add ../../flake.lock
git commit -m "init ${DEVICE}: $(date +"&D &T")"
git push -f

echo "######install finished SW######"
### Unmount filesystems:
umount -Rl /mnt
zpool export -a

### Reboot:
echo "reboot"
echo "add user by 'useradd -m <user>'"
#shutdown -P now
#reboot

#
# Decrypt LUKS
# cryptsetup luksOpen /dev/diby-id/nvme-INTEL_SSDPEKNW512G8_BTNH94660R3N512A-part3 tmpData
#
# Using github :
# - Add ssh first and do github jobs
# sudo -i
# cp ../ssh /home/nixos/.ssh
# chmod -R 700 /home/nixos/.ssh
# ssh-add /home/nixos/.ssh/id_ed25519
# git push -f
