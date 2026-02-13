# Raspberry Pi 4
{ config, lib, pkgs, modulesPath, ... }:
let

  name = "rp4";

in
{
  nixpkgs.system = "aarch64-linux";

  services.journald.extraConfig = ''
    Storage = volatile
    RuntimeMaxFileSize = 10M
  '';

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    useNetworkd = true;
    useDHCP = true;
    hostName = name;
  };

  networking.wireless.enable = false;

  # Uncomment and configure for WiFi:
  # networking.wireless.networks = {
  #   "YourSSID" = {
  #     pskRaw = "your-password";
  #   };
  # };

  # Alternative: Use iwd for wireless management
  # services.iwd.enable = true;
  # services.iwd.settings = {
  #   General = {
  #     EnableNetworkConfiguration = true;
  #   };
  #   Network = {
  #     Name = "YourSSID";
  #     Passphrase = "your-password";
  #   };
  # };

  hardware = {
    raspberry-pi."4".config-v3d.enable = true;
    raspberry-pi."4".bluetooth.enable = true;
    deviceTree.enable = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

  systemd.network.networks."eth0" = {
    matchConfig.Name = "eth0";
    gateway = [ "192.168.1.1" ];
    address = [
      "192.168.1.15/24"
    ];
  };

  environment.systemPackages = with pkgs; [ vim ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.piman = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  time.timeZone = "Europe/Madrid";

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    kernelParams = [ "snd_bcm2835.enable_hdmi=1" ];
    initrd = {
      includeDefaultModules = false;
      availableKernelModules = [
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "mmc_block"
      ];
      kernelModules = [ "hidp" ];
    };
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  system.stateVersion = "25.11";
}