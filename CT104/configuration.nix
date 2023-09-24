{ inputs, lib, config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/virtualisation/lxc-container.nix> ];
  time.timeZone = "Europe/Stockholm";

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
    btop
    docker-compose
  ];

hardware.opengl.extraPackages = with pkgs; [
  rocm-opencl-icd
  rocm-opencl-runtime
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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOltNlDAwXAw2mfdyMtdleOCfPQB2GSQ9l5W9cKbg+5i supern@kieeps.com"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIA5UjtYVIaojFVR95EUqe2jwpR25auHVRnhTa+5HrysEAAAABHNzaDo= kieeps@Lappen"
      ];
      extraGroups = [ "wheel" "docker" "video" "render" ];
    };
  };

  programs.bash.shellAliases = {
  gpull = "git --git-dir=/home/kieeps/compose/.git/ pull origin main";
  la = "ls -als";
  ls = "ls --color=tty";
  };

  ## virtualisation
  virtualisation.docker.enable = true;

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