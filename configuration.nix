# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  ...
}:
let
  haskellPackages = with pkgs; [
    ghc
    cabal-install
    haskell-language-server
  ];
  fontPackages = (
    with pkgs.nerd-fonts;
    [
      fira-code
      gohufont
      hack
      lilex
      overpass
    ]
  );
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./home.nix
  ];

  nix = {
    package = pkgs.lix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "seafoam"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  security.sudo.extraConfig = ''
    Defaults:USER timestamp_timeout=30
  '';

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  services.udev.packages = with pkgs; [
    # Needed for accessing /dev/hidraw devices.
    # See https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/op/opentabletdriver/package.nix
    opentabletdriver
  ];

  services.smartd = {
    enable = true;
    devices = [
      {
        device = "/dev/disk/by-id/ata-CT1000BX500SSD1_2128E5B78645";
      }
    ];
  };

  hardware.opentabletdriver.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # These are all considered "any-user critical".
  # Anything that is not needed by root can
  # be in their user profiles.
  environment.systemPackages =
    with pkgs;
    [
      # Compression tooling
      _7zz
      zip
      unzip

      curl
      evtest-qt # For udev event testing
      fastfetch
      fd
      file
      fish
      htop
      hyfetch
      iotop
      kdePackages.partitionmanager # For configuring disk partitions
      kotlin
      neovim
      nixos-rebuild-ng # Faster/safer nixos-rebuild
      opentabletdriver # Doesn't usually work, but still useful to have
      qt6Packages.qtstyleplugin-kvantum
      ripgrep
      samba # For Windows server set up
      smartmontools # For disk monitoring
      tmux
      tree
      usbutils
      wget
      xdg-utils
      xp-pen-deco-01-v2-driver # Proprietary Artist 12 2nd Gen driver
    ]
    ++ haskellPackages
    ++ fontPackages;

  programs.neovim = {
    defaultEditor = true;
  };

  qt = {
    enable = true;
    style = "kvantum";
    platformTheme = "kde6";
  };

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
  system.stateVersion = "24.11"; # Did you read the comment?
}
