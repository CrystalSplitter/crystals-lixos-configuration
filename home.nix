{
  config,
  pkgs,
  ...
}:
let
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
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.crystal =
    { pkgs, ... }:
    let
      cliPkgs = with pkgs; [
        tig # Git TUI history viewer
      ];
      desktopPkgs = with pkgs; [
        blender # 3D Modelling program
        clementine # Music player
        gitnuro # Git GUI client
        inkscape # Vector art program
        kdePackages.kate # Text editor
        kicad # Electronics
        krita # Raster art program
        obsidian # Note taking app
        discord # Chat app
        transmission_4-qt # Torrent client
        vesktop # Chat app wrapper
      ];
      corporatePkgs = with pkgs; [
        zoom-us # Video call app
      ];
    in
    {
      home.packages = cliPkgs ++ desktopPkgs ++ corporatePkgs;
      home.stateVersion = "24.11";
      programs = {
        alacritty = {
          enable = true;
          settings = {
            env.TERM = "xterm-256color";
          };
        };

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
        };
      };
    }
    // theme;
  programs.fish.enable = true;
  programs.steam.enable = true;
}
