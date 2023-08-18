{ config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/virtualisation/lxc-container.nix> ];

  ## Services
  services.openssh.enable = true;

  ## Packages
  environment.systemPackages = with pkgs; [
    git
    wget
  ];
  system.stateVersion = "23.05";
}