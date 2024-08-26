


# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual (accessible by running ‘nixos-help’).


{ config, pkgs, ... }:
let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };
#  programs.zsh.enable = true;
boot.binfmt.registrations.appimage = {
  wrapInterpreterInShell = false;
  interpreter = "${pkgs.appimage-run}/bin/appimage-run";
  recognitionType = "magic";
  offset = 0;
  mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
  magicOrExtension = ''\x7fELF....AI\x02'';
};

  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    shellAliases = {
      cp = "rsync -avh --inplace --no-whole-file --no-compress --progress --info=progress2";
      nanoc = "sudo nano /etc/nixos/configuration.nix";
    };
    ohMyZsh = {
      enable = true;
      theme = "bira";
      customPkgs = with pkgs; [
        zsh-git-prompt
        zsh-nix-shell
        zsh-completions
        zsh-command-time
        zsh-fast-syntax-highlighting
        nix-zsh-completions
      ];
    };
  };

# Steam
  programs.steam = {
    enable = true;
#    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

# ADB
  programs.adb = {
    enable = true;
  };

#  oh-my-zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Bootloader.
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.theme = true;
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.systemd-boot.configurationLimit = 10;
  # Vulcan
  # hardware.opengl.driSupport = true;
  # For 32 bit applications
  # hardware.opengl.driSupport32Bit = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot


  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  nix.settings.experimental-features = [ "nix-command flakes" ];
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Teamviewer 
#  services.teamviewer.enable = true;
  # enable the tailscale service
  services.tailscale.enable = true;
  # enable netbird service
#  services.netbird.enable = true;
  # enable TLP Service
  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;

  ## virtualisation
  virtualisation = {
    waydroid = {
      enable = true;
    };
    containers = {
      enable = true;
    };
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  virtualisation.libvirtd = {
  enable = true;
  qemu = {
    package = pkgs.qemu_kvm;
    runAsRoot = true;
    swtpm.enable = true;
    ovmf = {
      enable = true;
      packages = [(pkgs.unstable.OVMF.override {
        secureBoot = true;
 #       tpmSupport = true;
      }).fd];
    };
  };
};
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  # services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.xserver.displayManager = {
    lightdm = { 
      enable = true; 
      greeter.enable = false; 
    };
  };


  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect = {
    enable = true;
  };
  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "se";
    xkb.variant = "";
    videoDrivers = [ "amdgpu" ];
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kieeps = {
    isNormalUser = true;
    description = "kieeps";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "podman" "render" "video" ];
    packages = with pkgs; [
      kcalc
      firefox
      kate
      discord
      yakuake
      google-chrome
      signal-desktop
      git
      htop
      element-desktop
      cups-brother-hl1210w
      nextcloud-client
      libreoffice
      tlp
      yubico-pam
      nheko
      yubikey-manager-qt
      cmatrix
      spice
      spice-gtk
      moonlight-qt
      p7zip
      vscode
      warp-terminal
      podman-desktop
      android-tools
      android-udev-rules
      btop
      lutris
      vscode
     (wineWowPackages.full.override {
       wineRelease = "staging";
       mingwSupport = true;
     })
     winetricks
    ];
  };

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "kieeps";

 


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  
environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  pkgs.rocmPackages.rocm-smi  
];
  # programs.btop.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
environment.sessionVariables = {
  MOZ_USE_XINPUT2 = "1";
};


  system.stateVersion = "23.11"; # Did you read the comment?

}
