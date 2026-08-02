{
  pkgs,
  config,
  lib,
  ...
}:
let
  mkPluginFromName = name: {
    inherit name;
    src = pkgs.fishPlugins.${name}.src;
  };

  nixpkgFishPlugins = map mkPluginFromName [ "hydro" ];
  myFishPlugins = nixpkgFishPlugins;

in
{
  config = {
    programs.fish = {
      enable = true;
      shellInit = builtins.readFile ../dotfiles/fish/config.fish;
      plugins = myFishPlugins;
    };

    xdg.configFile = let
      confd = ../dotfiles/fish/conf.d;
      confFiles = builtins.attrNames (builtins.readDir confd);
      configFunc = file: { "fish/conf.d/${file}" = {
          source = "${confd}/${file}";
          recursive = true;
        };
      };
    in lib.attrsets.mergeAttrsList (map configFunc confFiles);
  };
}
