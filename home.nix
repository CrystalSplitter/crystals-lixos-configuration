{
  config,
  pkgs,
  lib,
  ...
}:
let

  # Args:
  #  sets - List of attribute sets to merge together.
  #
  # Returns:
  #  A new attribute set with all the `sets` values combined.
  recursiveMerge = sets: lib.foldr lib.recursiveUpdate { } sets;

  alacrittyConfig = {
    xdg.configFile = {
      "alacritty" = {
        source = ./dotfiles/alacritty;
        recursive = true;
      };
    };
  };

  weztermConfig = {
    xdg.configFile = {
      "wezterm" = {
        source = ./dotfiles/wezterm;
        recursive = true;
      };
    };
  };

  # Original upstream otto theme.
  orig-otto-theme = builtins.fetchTarball {
    url = "https://gitlab.com/jomada/otto/-/archive/master/otto-master.tar.gz";
    sha256 = "084p705prjmsz9wgkr1lpgjkyj8j2s9n8pb9fjgbk67fxy52mh77";
  };

  # Custom otto theme.
  otto-theme = ./dotfiles/Kvantum/Otto;

  theme = {
    xdg.configFile = {
      "Kvantum/Otto".source = otto-theme;
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=Otto
      '';
    };
  };

in
{
  # For opening links in external xdg-open browsers
  # See https://github.com/NixOS/nixpkgs/issues/330916#issuecomment-2260781383
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common.default = "kde";
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.crystal = {
    isNormalUser = true;
    description = "Crystal";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
    # Rest of packages configured in home.nix
  };
  
  # Needed for neochat
  # *sigh* ..........
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.crystal =
    { pkgs, ... }:
    let
      cliPkgs = with pkgs; [
        clang-tools # Includes things like clangd
        shellcheck # Linter for BASH-like files
        tig # Git TUI history viewer
        wl-clipboard # Wayland clipboard provider
      ];
      desktopPkgs = with pkgs; [
        # alacritty # Terminal emulator
        blender # 3D Modelling program
        clementine # Music player
        feh # Image displayer
        firefox # Browser
        fluent-reader
        gitnuro # Git GUI client
        inkscape # Vector art program
        kdePackages.kate # Text editor
        kdePackages.neochat
        kicad # Electronics
        krita # Raster art program
        libreoffice-qt6 # Office tool suite
        obsidian # Note taking app
        transmission_4-qt # Torrent client
        vesktop # Chat app wrapper
        wezterm # Terminal emulator
      ];
      corporatePkgs = with pkgs; [
        zoom-us # Video call app
      ];
      pythonPkgs = with pkgs.python313Packages; [
        python # Python interpreter
        black # Code formatter
      ];
      winePkgs = with pkgs.wineWowPackages; [
        full
      ];
    in
    recursiveMerge [
      {
        imports = [
          ./modules/discord_wrapper.nix
        ];

        home.packages = cliPkgs ++ pythonPkgs ++ desktopPkgs ++ corporatePkgs ++ winePkgs;
        home.stateVersion = "24.11";

        programs = {

          # # For discord Krisp support, provided by discord_wrapper.nix
          # discord = {
          #   enable = true;
          #   wrapDiscord = true;
          # };

          chromium.enable = true;
          firefox.enable = true;

          fish = {
            enable = true;
            shellInit = builtins.readFile ./dotfiles/fish/config.fish;
          };

          git = {
            enable = true;
            package = pkgs.gitFull;
            userEmail = "crystal@crystalwobsite.gay";
            userName = "CrystalSplitter";
            lfs.enable = true;
          };

          neovim = {
            enable = true;
            defaultEditor = true;
            plugins = with pkgs.vimPlugins; [
              # Libraries
              plenary-nvim
              nvim-web-devicons
              nui-nvim

              lualine-nvim
              neogit
              neo-tree-nvim
              nvim-lspconfig
            ];
            extraLuaConfig = ''
              vim.lsp.enable('clangd')
              require('lualine').setup()

              vim.opt.expandtab = true
              vim.opt.shiftwidth = 4
              vim.opt.tabstop = 4
              vim.opt.number = true
              vim.opt.signcolumn = 'yes'
            '';
          };
        };
      }
      weztermConfig
      theme
    ];
  programs.fish.enable = true;
  programs.steam.enable = true;

  # Some programs work better in flatpak than nix, and this
  # is especially valuable when conducting testing.
  services.flatpak.enable = true;
}
