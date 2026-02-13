{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  #iot = config.homelab.networks.local.iot.reservations;
  #tvIpAddress = iot.lgtv.Address;
  #tvMacAddress = iot.lgtv.MACAddress;
in
{
  imports = [
    ../../misc/ryzen-undervolting
    #../../misc/lgtv
    inputs.jovian.nixosModules.default
  ];

  environment.systemPackages = [
    pkgs.s-tui
    pkgs.stress
    pkgs.firefox-bin
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

  services = {
    desktopManager.plasma6.enable = true;
  };

  networking = {
    networkmanager.enable = true;
    hostName = "steamwhite";
    hostId = "899635ed";
    interfaces.enp4s0.wakeOnLan = {
      enable = true;
    };
  };

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
}
