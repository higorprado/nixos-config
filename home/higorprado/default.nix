{ pkgs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    
    users.higorprado = {
      home.username = "higorprado";
      home.homeDirectory = "/home/higorprado";
      home.stateVersion = "25.11";
      home.sessionVariables = { 
        TERMINAL = "ghostty";
      };

      imports = [
        ./fish.nix
        ./mise.nix
        ./ghostty.nix
      ];

      home.packages = with pkgs; [
        starship
        ghostty
      ];
    };
  };
}
