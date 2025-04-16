{
  config,
  pkgs,
  inputs,
  ...
}:
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
    };
  programs.fish.enable = true;
  programs.steam.enable = true;
}
