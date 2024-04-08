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

### System packages
  environment.systemPackages = with pkgs; [
    wget
    tailscale
    git
    btop
    docker-compose
    xclip
    screen
    google-chrome
    (python310.withPackages(ps: with ps; [ docker ]))
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

  networking.hostName = "nixos-hetzner";

  users.users = {
    kieeps = {
      initialPassword = "kieeps2win";
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" "docker" ];
    };
  };
    users.users = {
    ansible = {
      initialPassword = "ansible2win";
      isNormalUser = true;
      uid = 1001;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+dFVrzTCoGKIzTdazKVFmmQWc0tGTcj35EewEwlcyL ansible@kieeps.com"
      ];
      extraGroups = [ "wheel" "docker" "video" "render" ];
    };
  };

    users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+dFVrzTCoGKIzTdazKVFmmQWc0tGTcj35EewEwlcyL ansible@kieeps.com"
      ];
      extraGroups = [ "root" ];
    };
  };


  programs.bash.shellAliases = {
  gp = "git pull";
  cdc = "cd compose";
  dcp = "docker-compose pull";
  dcu = "docker-compose up";
  la = "ls -als";
  ls = "ls --color=tty";
  c = "xclip";
  v = "xclip -o";

  };

  ## virtualisation
  virtualisation.docker.enable = true;

  ## Services
  services.tailscale.enable = true;
  services.teleport = { 
    enable = true;
    package = pkgs.teleport;
  };
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    #settings.PermitRootLogin = "yes";
 };
  system.stateVersion = "23.05";
}