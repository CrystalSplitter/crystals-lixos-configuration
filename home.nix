{ 
  config,
  pkgs,
  inputs,
  ...
}:
{
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.crystal = { pkgs, ... }: {
    home.packages = with pkgs; [
      inkscape
      kdePackages.kate
      krita
      transmission_4-qt
      vesktop
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
        userName = "CrystalSplitter";
        userEmail = "crystalwobsite.gay";
      };
    };
  };
  programs.fish.enable = true;
  programs.steam.enable = true;
}
