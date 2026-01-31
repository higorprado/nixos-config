{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim neovim
    wget curl git unzip
    ripgrep file binutils breakpad
    htop btop
    firefox chromium
    logiops
    libsecret
    xwayland-satellite
    nvtopPackages.nvidia
    nix-output-monitor
    papirus-icon-theme
    tela-icon-theme
    
    # Electron com fix de flickering
    (vscode.override {
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--enable-features=UseOzonePlatform,WaylandWindowDecorations"
        "--use-gl=egl"
      ];
    })
    
    (google-chrome.override {
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--enable-features=UseOzonePlatform,WaylandWindowDecorations"
        "--use-gl=egl"
      ];
    })
  ];
  
  fonts.packages = with pkgs; [
    noto-fonts noto-fonts-color-emoji noto-fonts-cjk-sans
    fira-code fira-code-symbols
    nerd-fonts.fira-code
  ];
}