{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim neovim
    wget curl git unzip
    htop btop
    firefox chromium
    libsecret

    # recomendo ficar no vscode normal e só migrar pra FHS se algum plugin quebrar
    vscode

    xwayland-satellite
  ];

  fonts.packages = with pkgs; [
    noto-fonts noto-fonts-color-emoji noto-fonts-cjk-sans
    fira-code fira-code-symbols
    nerd-fonts.fira-code
  ];
}
