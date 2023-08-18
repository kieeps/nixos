{ config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/virtualisation/lxc-container.nix> ];
  time.timeZone = "Europe/Stockholm";

  ## Supress systemd units that don't work because of LXC
  systemd.suppressedSystemUnits = [
    "dev-mqueue.mount"
    "sys-kernel-debug.mount"
    "sys-fs-fuse-connections.mount"
  ];

  # Configure console keymap
  console.keyMap = "sv-latin1";

  ## Services
  services.openssh.enable = true;
  services.tailscale.enable = true;

  ## Packages
 environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];
  system.stateVersion = "23.05";
}