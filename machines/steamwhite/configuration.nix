{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    ../../misc/ryzen-undervolting
    #../../misc/lgtv
    inputs.jovian.nixosModules.default
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  time.timeZone = "Europe/Madrid";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_BE.UTF-8";
    LC_IDENTIFICATION = "nl_BE.UTF-8";
    LC_MEASUREMENT = "nl_BE.UTF-8";
    LC_MONETARY = "nl_BE.UTF-8";
    LC_NAME = "nl_BE.UTF-8";
    LC_NUMERIC = "nl_BE.UTF-8";
    LC_PAPER = "nl_BE.UTF-8";
    LC_TELEPHONE = "nl_BE.UTF-8";
    LC_TIME = "nl_BE.UTF-8";
  };

  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "be";
    variant = "nodeadkeys";
  };

  console.keyMap = "be-latin1";

  services.printing.enable = true;

  services.flatpak.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.fwupd.enable = true;

  nixpkgs.config.allowUnfree = true;

  nix.gc.automatic = true;
  nix.gc.dates = "weekly";

  users.users.thijzer = {
    isNormalUser = true;
    description = "Thijzer";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  environment.systemPackages = with pkgs; [
    vim
    ghostty
    git
    btop
    s-tui
    stress
    firefox-bin
  ];

  hardware = {
    bluetooth.enable = lib.mkForce false;
    enableRedistributableFirmware = true;
    cpu.amd = {
      updateMicrocode = true;
      ryzen-smu.enable = true;
    };
    xone.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  networking = {
    networkmanager.enable = true;
    hostName = "steamwhite";
    hostId = "899635ed";
    interfaces.enp4s0.wakeOnLan = {
      enable = true;
    };
  };

  virtualisation = {
    docker.enable = true;
    podman = {
      enable = true;
      dockerCompat = false;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services.tailscale.enable = true;

  jovian = {
    hardware = {
      has.amd.gpu = true;
      amd.gpu.enableBacklightControl = false;
    };
    steam = {
      updater.splash = "vendor";
      enable = true;
      autoStart = true;
      user = "thijzer";
      desktopSession = "plasma";
    };
    steamos = {
      useSteamOSConfig = true;
    };
  };

  system.stateVersion = "25.11";
}
