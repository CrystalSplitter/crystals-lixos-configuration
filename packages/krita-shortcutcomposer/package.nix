{
  pkgs,
  stdenv,
  ...
}:
let
  installDir = "share/krita/pykrita";

in
stdenv.mkDerivation {
  pname = "krita-shortcutcomposer";
  version = "1.5.4";
  license = "GPL-3.0-only";
  src = pkgs.fetchFromGitHub {
    owner = "wojtryb";
    repo = "Shortcut-Composer";
    rev = "v1.5.4";
    hash = "sha256-XQuP0GeCcOIgbVatIynC4K9obdM8teeK5skq/8tF7sc=";
  };
  installPhase = ''
    runHook preInstall

    mkdir -p $out/${installDir}
    cp -r shortcut_composer $out/${installDir}
    cp shortcut_composer.desktop $out/${installDir}

    runHook postInstall
  '';
}
