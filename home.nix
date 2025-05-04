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

  otto-theme-tar = builtins.fetchTarball {
    url = "https://gitlab.com/jomada/otto/-/archive/master/otto-master.tar.gz";
    sha256 = "084p705prjmsz9wgkr1lpgjkyj8j2s9n8pb9fjgbk67fxy52mh77";
  };

  theme = {
    xdg.configFile = {
      "Kvantum/Otto".source = "${otto-theme-tar}/kvantum/Otto";
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

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.crystal =
    { pkgs, ... }:
    let
      cliPkgs = with pkgs; [
        tig # Git TUI history viewer
        wl-clipboard # Wayland clipboard provider
      ];
      desktopPkgs = with pkgs; [
        # alacritty # Terminal emulator
        blender # 3D Modelling program
        clementine # Music player
        firefox # Browser
        gitnuro # Git GUI client
        inkscape # Vector art program
        kdePackages.kate # Text editor
        kicad # Electronics
        krita # Raster art program
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
    in
    recursiveMerge [
      {
        imports = [
          ./modules/discord_wrapper.nix
        ];

        home.packages = cliPkgs ++ pythonPkgs ++ desktopPkgs ++ corporatePkgs;
        home.stateVersion = "24.11";
        programs = {

          # For discord Krisp support, provided by discord_wrapper.nix
          discord = {
            enable = true;
            wrapDiscord = true;
          };

          firefox = {
            enable = true;
          };

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
              plenary-nvim
              nvim-web-devicons
              nui-nvim

              lualine-nvim

              neogit
              neo-tree-nvim
            ];
            extraLuaConfig = ''
                          vim.opt.expandtab = true
                          vim.opt.shiftwidth = 4
                          vim.opt.tabstop = 4

                          require('lualine').setup()
              	      '';
          };
        };
      }
      # alacrittyConfig
      weztermConfig
      theme
    ];
  programs.fish.enable = true;
  programs.steam.enable = true;
}
