{ pkgs ? import <nixpkgs> { } }: # function to generate shell; if no pakges is passed, set it to nixpkgs; frowned upon in the official nixpkgs but possible in personal shell
let
  myScript = pkgs.writeScriptBin "foobar" ''
    echo "Foobar" | figlet
  '';
in
pkgs.mkShell { 
  name = "MyAwesomeShell";
  buildInputs = with pkgs; [
    figlet # packages that will actually be in the shell; can add python, ruby or anything 
    myScript
    nixFlakes
  ];

  shellHook = ''
    echo "Welcome to my awesome shell"; # like start script
  '';
}

