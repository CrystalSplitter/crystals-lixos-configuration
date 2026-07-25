{
  pkgs,
  config,
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
  };
}
