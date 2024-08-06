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
    git
    btop
    screen
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

  networking.hostName = "teleport";

  users.users = {
    kieeps = {
      initialPassword = "kieeps2win";
      isNormalUser = true;
      uid = 1000;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOltNlDAwXAw2mfdyMtdleOCfPQB2GSQ9l5W9cKbg+5i supern@kieeps.com"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIA5UjtYVIaojFVR95EUqe2jwpR25auHVRnhTa+5HrysEAAAABHNzaDo= kieeps@Lappen"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJ+BbPDmvbxe8F0PRqJb8eQ/S0PFvHpd21/3W3t1zXe obelix@kieeps.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtSbMFj9DxS5nb3F2tDHRNpw9UxRmIBYLaZvgydIu0r root@HomeSense.local"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvlBIhC5sxCAP0wzdKV23efXXPQ7P2ToxJdxQEmChr4 JuiceSSH"
      ];
      extraGroups = [ "wheel" ];
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
  la = "ls -als";
  ls = "ls --color=tty";
  };


  ## Services

  # Teleport
  systemd.services.teleport.path = [ pkgs.getent ];
  services.teleport = { 
    enable = true;
    package = pkgs.teleport_16;
    settings = {
      teleport = {
        nodename = "teleport-main";
        # data_dir =  /var/lib/teleport;

      };
      auth_service = {
        enabled = true;
        listen_addr = "0.0.0.0:3025";
        proxy_listener_mode = "multiplex";
        cluster_name = "teleport.kieeps.com";
        client_idle_timeout = "never";
      };
      ssh_service = {
        enabled = true;
      };
      proxy_service = {
        enabled = true;
        web_listen_addr = "0.0.0.0:443";
        public_addr = teleport.kieeps.com:443;
        https_keypairs = [
          { key_file = "/root/cert/kieeps.com/key.pem"; cert_file = "/root/cert/kieeps.com/fullchain.pem"; }
          { key_file = "/root/cert/teleport.kieeps.com/key.pem"; cert_file = "/root/cert/teleport.kieeps.com/fullchain.pem"; }
        ];
      };
      app_service = {
        enabled = true;
        apps = [
          { name = "opnsense"; uri = "http://192.168.1.1:8899/"; public_addr = ""; insecure_skip_verify = true; }
          { name = "semaphore"; uri = "http://192.168.1.170:3000"; public_addr = ""; insecure_skip_verify = false; }
          { name = "proxmox"; uri = "https://192.168.1.3:8006"; public_addr = ""; insecure_skip_verify = true; }
          { name = "idrac"; uri = "https://192.168.1.11"; public_addr = ""; insecure_skip_verify = false; }
          { name = "pikvm"; uri = "https://192.168.1.15:443"; public_addr = ""; insecure_skip_verify = true; }
        ];
      };
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "yes";
 };
  system.stateVersion = "23.05";
}
