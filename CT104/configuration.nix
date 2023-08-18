{ config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/virtualisation/lxc-container.nix> ];
  time.timeZone = "Europe/Stockholm";
  ## Services
  services.openssh.enable = true;
  services.tailscale.enable = true;

  ## Packages
  environment.systemPackages = with pkgs; [
    tailscale
    git
    wget
  ];
  system.stateVersion = "23.05";
}