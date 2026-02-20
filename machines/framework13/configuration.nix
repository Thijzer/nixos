# NixOS Configuration for Cronos (Framework 13 AMD)
# Location: /etc/nixos/configuration.nix

{ config, pkgs, ... }:
let
  unstable = import <unstable> {config.allowUnfree = true;};
in
{
#  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [
      <nixos-hardware/framework/13-inch/7040-amd>
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Make these kernel modules available in the initrd (early boot environment).
  # This helps ensure the system can see your storage and USB controllers
  # before the real root filesystem is mounted.
  # - nvme: NVMe SSD support
  # - xhci_pci: USB 3.x controller support
  # - thunderbolt: Thunderbolt bus support
  # - usb_storage: USB mass storage (USB drives)
  # - sd_mod: SCSI disk layer used by many disk-like devices (incl. some USB/SATA paths)
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod"];

  # Force-disable TLP (laptop power management), even if some other imported
  # module/profile tries to enable it elsewhere.
  services.tlp.enable = false;
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # Latest kernel for Framework 13 hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x10"
    "mem_sleep_default=s2idle"
    "amdgpu.dcdebugmask=0x10"
    "pcie_aspm=off"
  ];

  services.logind.settings.Login.HandleLidSwitch = "suspend";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "suspend";
  services.logind.settings.Login.HandleLidSwitchDocked = "suspend";

  networking.hostName = "framework13";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openconnect ];

  # Set your time zone
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties
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

  # Enable the X11 windowing system
  services.xserver.enable = false;

  # Enable KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable Flatpak
  services.flatpak.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "be";
    variant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "be-latin1";

  # Enable CUPS to print documents
  #services.printing.enable = true;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true; # Open ports in the firewall for Syncthing. (NOTE: this will not open syncthing gui port)
    user = "thijzer";
    dataDir = "/home/thijzer";  # default location for new folders
    configDir = "/home/thijzer/.config/syncthing";
  };

  users.extraUsers.thijzer = {
    shell = pkgs.zsh;
  };

  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "z"
      ];
      custom = "$HOME/.oh-my-zsh/custom/";
      theme = "powerlevel10k/powerlevel10k";
    };
  };

  #programs.ssh.startAgent = true;

  # Enable KDE Connect
  programs.kdeconnect.enable = true;

  # Define a user account
  users.users.thijzer = {
    isNormalUser = true;
    description = "thijzer";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      # Productivity & Dev
      google-chrome
      filezilla
      postman
      jetbrains.phpstorm
      vscode
      dbeaver-bin
      obsidian
      zed-editor
      teams-for-linux
      opencode
      localsend
      ansible
      distrobox

      # GNOME Extensions
      # gnomeExtensions.caffeine
      # gnomeExtensions.gsconnect
      # gnomeExtensions.clipboard-indicator
      # gnomeExtensions.appindicator
      # gnomeExtensions.vitals
    ];
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [
    vim
    ghostty
    git
    btop

    ripgrep        # rg
    fd
    gnused         # sed
    gawk           # awk
    coreutils      # ls, cat, cp, mv, wc, sort, ...
    findutils      # find, xargs
    gnugrep        # grep
    diffutils      # diff
    patch
    jq
    bash
    curl
    wget
    gnutar         # tar
    gzip
    unzip
    gnumake        # make
    which
    util-linux

    unstable.intune-portal
  ];

  # gnome keyring dependency of intune-prortal
  security.pam.services.login.enableGnomeKeyring = true;

  services = {
    dbus.packages = with pkgs; [ gcr ];
    gnome.gnome-keyring.enable = true;
  };


  # Allow unfree packages (Chrome, PHPStorm, etc.)
  nixpkgs.config.allowUnfree = true;

  # Enable common hardware services for Framework
  services.fwupd.enable = true;
  services.fprintd.enable = true; # Fingerprint sensor support
  security.pam.services = {
    sudo = {
      fprintAuth = true;
      unixAuth = true; # fallback to password
    };
    polkit-1 = {
      fprintAuth = true;
      unixAuth = true; # fallback to password
    };
  };
  security.polkit.enable = true;

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable Docker and Podman
  virtualisation = {
    docker.enable = true;
    podman = {
      enable = true;
      dockerCompat = false; # Set to true if you want 'docker' command to alias to podman
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Enable Tailscale
  services.tailscale.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
