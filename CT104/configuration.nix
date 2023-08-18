{ inputs, lib, config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/virtualisation/lxc-container.nix> ];
  time.timeZone = "Europe/Stockholm";

  modules = [ arion.nixosModules.arion ];

  ## Supress systemd units that don't work because of LXC
  systemd.suppressedSystemUnits = [
    "dev-mqueue.mount"
    "sys-kernel-debug.mount"
    "sys-fs-fuse-connections.mount"
  ];

  environment.systemPackages = with pkgs; [
    wget
    tailscale
    git

  ];

  nixpkgs = {
    overlays = [
    ];

    config = {
      allowUnfree = true;
    };
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  networking.hostName = "nixos-docker";

  users.users = {
    kieeps = {
      initialPassword = "kieeps2win";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1maslZL3A8TF4lSHY0BzUtZ+TEa9Jypp+ecUyVZnYG supern@kieeps.com"
      ];
      extraGroups = [ "wheel" ];
    };
  };

  ## virtualisation
  virtualisation.docker.enable = true;
  virtualisation.arion = {
   backend = "docker";
    projects = {
      "jellyfin" = settings.services."jellyfin".service = {
        image = "lscr.io/linuxserver/jellyfin:latest";
        restart = "unless-stopped";
        environment = { PUID=1000; PGID=1000; TZ=Etc/UTC; };
        ports = {"8096"};
      };
    };
  };

  ## Services
  services.tailscale.enable = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    #settings.PermitRootLogin = "yes";
 };
  system.stateVersion = "23.05";
}