# NixOS Configuration for Cronos (Framework 13 AMD)
# Location: /etc/nixos/configuration.nix

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Latest kernel for Framework 13 hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "framework13";

  # Enable networking
  networking.networkmanager.enable = true;

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
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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
  services.printing.enable = true;

  # Enable sound with pipewire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users = {
    # password: temp a
    root.initialHashedPassword = "$6$FRmKgElD/80xQiXn$aF.tKv0VOLj9D3aUJjoYsj3AzSj1rq5fVooE7tgtNuTawt8ZWgaRyUUxsikX5whbna4jrzXrDZmVFqik.kyc2/";
  };

  # Define a user account
  users.users.thijzer = {
    # password: temp b
    initialHashedPassword = "$6$iLmo7C9VoAnJZ6v1$qCSORkbiY44IbcrrF1DcTnJtpOkqeD2tGgUoaDgtzPdFqKWKJ28AhJqmuOf8IWoSNu2DQJM.QlWO1Ok05kFgp0";
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

      # GNOME Extensions
      gnomeExtensions.caffeine
      gnomeExtensions.gsconnect
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.appindicator
      gnomeExtensions.vitals
    ];
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [
    vim
    ghostty
    git
    btop
    # Note: zen-browser is often installed via a flake or specific overlay 
    # as it might not be in the standard nixpkgs yet.
    # Flatpak: app.zen_browser.zen
  ];

  # Allow unfree packages (Chrome, PHPStorm, etc.)
  nixpkgs.config.allowUnfree = true;

  # Enable common hardware services for Framework
  services.fwupd.enable = true;
  services.fprintd.enable = true; # Fingerprint sensor support
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

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
