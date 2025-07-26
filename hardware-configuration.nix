{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b028a5c3-c289-4fc7-b339-aeebd0c69c24";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "noatime"
      "nodiratime"
      "discard"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/b028a5c3-c289-4fc7-b339-aeebd0c69c24";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "noatime"
      "nodiratime"
      "discard"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F1E7-E542";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/ee98e736-e1bf-4d98-914d-7928176dee7b"; }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.smartd = {
    enable = true;
    devices = [
      {
        device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_1TB_S74ZNX0Y413968D";
      }
    ];
  };

}
