# NixOS Configurations

This repository contains NixOS configurations for multiple machines.

## Machines

| Machine | Type | Description |
|---------|------|-------------|
| `steamwhite` | Desktop | Gaming PC with Ryzen CPU, AMD GPU, Steam/Jovian |
| `thinkpadx1` | Laptop | ThinkPad X1 Carbon, KDE Plasma |
| `framework13` | Laptop | Framework 13 AMD, GNOME |
| `raspberrypi4` | ARM64 | Raspberry Pi 4 |

## Directory Structure

```
.
├── machines/
│   ├── steamwhite/      # Gaming desktop config
│   ├── thinkpadx1/      # ThinkPad X1 laptop config
│   ├── framework13/     # Framework 13 laptop config
│   └── raspberrypi4/   # Raspberry Pi 4 config
└── misc/
    ├── ryzen-undervolting/
    └── lgtv/
```

## Building a Machine

### Using nix-env (Classic)

```bash
# Build system closure
sudo nix-build '<nixpkgs/nixos>' -A system -I nixos-config=./machines/steamwhite

# Or build directly from configuration
sudo nixos-rebuild switch -I nixos-config=./machines/steamwhite/configuration.nix
```

### Using Flakes (Recommended)

Add a `flake.nix` to the root:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations = {
      steamwhite = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./machines/steamwhite/configuration.nix ];
      };
      # Add other machines...
    };
  };
}
```

Then:
```bash
# Build system
sudo nixos-rebuild switch --flake .#steamwhite

# Build ISO (for steamwhite)
nix build .#nixosConfigurations.steamwhite.config.system.build.isoImage
```

## Creating a Bootable ISO

For steamwhite, you can generate a bootable ISO by adding to `machines/steamwhite/configuration.nix`:

```nix
imports = [
  <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical.nix>
];

boot.loader.grub.enable = false;
```

Then build:
```bash
nix-build '<nixpkgs/nixos>' -A isoImage -I nixos-config=./machines/steamwhite/configuration.nix
```

## Common Tasks

### Generate Hardware Config

```bash
sudo nixos-generate-config --show-hardware-config > machines/<name>/hardware-configuration.nix
```

### Update Channels

```bash
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
sudo nix-channel --update
```

### Garbage Collection

```bash
# Remove old generations
sudo nix-collect-garbage -d

# Or with flakes
nix store gc
```
