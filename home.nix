{
  config,
  pkgs,
  lib,
  inputs,
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

  tmuxConfig = {
    xdg.configFile = {
      "tmux/tmux.conf" = {
        source = ./dotfiles/tmux.conf;
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

  # Args:
  #  plugins - vimPlugins package list (e.g. pkgs.vimPlugins)
  #
  # Returns:
  #  List of plugins to install.
  vim-plugins =
    plugins: with plugins; [

      # Libraries
      plenary-nvim
      # nvim-web-devicons (Icons)
      nui-nvim
      mini-icons # (Icons)

      gitsigns-nvim # Git gutter (neat!)
      indent-blankline-nvim # Indent support

      lualine-nvim
      neogit
      neo-tree-nvim
      nvim-lspconfig # Default LSP configs
      typescript-tools-nvim # Typescript LSP
      fzf-lua # FZF!

      sonokai # Colours
    ];

  nvimSharedConfig = {
    xdg.configFile = {
      "nvim" = {
        source = ./dotfiles/nvim_shared;
        recursive = true;
      };
    };
  };

  vim-config = ''
    vim.lsp.enable("clangd")
    vim.lsp.enable("hls")
    vim.lsp.enable("pyright")
    vim.lsp.enable("ts_ls")

    -- Icons
    require("mini.icons").setup()

    -- require("typescript-tools").setup {}
    require("options")
  '';

  vr-config = config: {
    # For Monado x OpenComposite
    xdg.configFile = {
      "openxr/1/active_runtime.json".source = "${pkgs.monado}/share/openxr/1/openxr_monado.json";
      "openvr/openvrpaths.vrpath".text = ''
        {
          "config": [
            "${config.xdg.dataHome}/Steam/config"
          ],
          "external_drivers": null,
          "jsonid": "vrpathreg",
          "log": [
            "${config.xdg.dataHome}/Steam/logs"
          ],
          "runtime": [
            "${pkgs.opencomposite}/lib/opencomposite"
          ],
          "version": 1
        }
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
      "wireshark"
    ];
    shell = pkgs.fish;
    # Rest of packages configured in home.nix
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "hm-backup";
  home-manager.users.crystal =
    { config, pkgs, ... }:
    let
      cliPkgs = with pkgs; [
        backblaze-b2 # Backup/cold-storage bucket utils
        clang-tools # Includes things like clangd
        shellcheck # Linter for BASH-like files
        tig # Git TUI history viewer
        wl-clipboard # Wayland clipboard provider
      ];
      desktopPkgs = with pkgs; [
        # (callPackage ./packages/krita-shortcutcomposer/package.nix {})
        # alacritty # Terminal emulator
        aseprite # Pixel art editor
        audacity # Audio editing tool
        blender # 3D Modelling program
        element-desktop # Matrix chat
        feh # Image displayer
        firefox # Browser
        fluent-reader
        fzf # Fuzzy finder
        gitnuro # Git GUI client
        godot # Game engine!
        halloy # IRC client
        inkscape # Vector art program
        itch # Indie game store
        kdePackages.kate # Text editor
        kicad # Electronics
        krita # Raster art program
        libreoffice-qt6 # Office tool suite
        obsidian # Note taking app
        signal-desktop # Messaging app
        strawberry # Music player
        transmission_4-qt # Torrent client
        usbimager # USB Image Flasher
        vesktop # Chat app wrapper
        vlc # Video player
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
        imports = [ ];

        home.packages = cliPkgs ++ pythonPkgs ++ desktopPkgs ++ corporatePkgs ++ winePkgs;
        home.stateVersion = "24.11";

        programs = {

          # For discord Krisp support, provided by discord_wrapper.nix
          # discord = {
          # enable = true;
          # wrapDiscord = true;
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
            settings = {
              user.name = "CrystalSplitter";
              user.email = "crystal@crystalwobsite.gay";
              commit.verbose = true;
            };
            lfs.enable = true;
          };

          neovim = {
            enable = true;
            defaultEditor = true;
            plugins = vim-plugins pkgs.vimPlugins;
            extraLuaConfig = vim-config;
          };
        };
      }
      weztermConfig
      theme
      tmuxConfig
      nvimSharedConfig
      (vr-config config)
    ];
  programs.fish.enable = true;
  programs.steam.enable = true;

  # Some programs work better in flatpak than nix, and this
  # is especially valuable when conducting testing.
  services.flatpak.enable = true;
}
