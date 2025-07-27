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
      nvim-web-devicons
      nui-nvim

      lualine-nvim
      neogit
      neo-tree-nvim
      nvim-lspconfig # Default LSP configs
      typescript-tools-nvim # Typescript LSP

      sonokai # Colours
    ];

  vim-config = ''
    vim.lsp.enable('clangd')
    vim.lsp.enable('hls')
    vim.lsp.enable('pyright')
    require("typescript-tools").setup {}

    -- --- Colours ---
    vim.o.termguicolors = true
    vim.g.sonokai_style = 'atlantis'
    vim.cmd.colorscheme('sonokai')

    require('lualine').setup {
      options = {
        theme = 'sonokai'
      }
    }

    -- --- Remappings and keybinds ---
    local keycode = vim.keycode
    vim.g.mapleader = keycode','

    -- Neotree
    vim.keymap.set('n', '<Leader>|', '<cmd>Neotree left reveal<cr>')
    vim.keymap.set('n', '<Leader>b', '<cmd>Neotree toggle show buffers right<cr>')

    -- Nvim LSP
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

    -- --- Generic ---
    vim.opt.expandtab = true
    vim.opt.shiftwidth = 4
    vim.opt.tabstop = 4
    vim.opt.signcolumn = 'yes'
    vim.opt.number = true
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
        audacity
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
        # (callPackage ./packages/krita-shortcutcomposer/package.nix {})
        libreoffice-qt6 # Office tool suite
        obsidian # Note taking app
        transmission_4-qt # Torrent client
        usbimager # USB Image Flasher
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

          # For discord Krisp support, provided by discord_wrapper.nix
          discord = {
            enable = true;
            # wrapDiscord = true;
          };

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
            extraConfig = {
              commit = {
                verbose = true;
              };
            };
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
      (vr-config config)
    ];
  programs.fish.enable = true;
  programs.steam.enable = true;

  # Some programs work better in flatpak than nix, and this
  # is especially valuable when conducting testing.
  services.flatpak.enable = true;
}
