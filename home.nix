{
  config,
  pkgs,
  inputs,
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
    {
      home.packages = with pkgs; [
        inkscape # Vector art program
        kdePackages.kate # Text editor
        krita # Raster art program
        transmission_4-qt # Torrent client
        vesktop
        tig # Git TUI history viewer
        gitnuro # Git GUI client
      ];
      home.stateVersion = "24.11";
      programs = {
        alacritty = {
          enable = true;
          settings = {
            env.TERM = "xterm-256color";
          };
        };
        firefox.enable = true;
        git = {
          enable = true;
          package = pkgs.gitFull;
          userEmail = "crystal@crystalwobsite.gay";
          userName = "CrystalSplitter";
        };
      };
    } // theme;
  programs.fish.enable = true;
  programs.steam.enable = true;
}
