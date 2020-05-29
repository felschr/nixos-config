{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    omnisharp-roslyn
  ];

  home.file.".omnisharp/omnisharp.json" = {
    text = ''
      {
        "FormattingOptions": {
          "EnableEditorConfigSupport": true
        },
        "RoslynExtensionsOptions": {
          "EnableAnalyzersSupport": true
        }
      }
    '';
  };
}
