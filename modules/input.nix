{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-gtk ];
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
    model = "pc105";
  };

  console.keyMap = "us-acentos";
}
