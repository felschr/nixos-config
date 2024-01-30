{ pkgs, ... }:

{
  home.packages = with pkgs; [
    trayscale
    (pkgs.makeAutostartItem {
      name = "dev.deedles.Trayscale";
      package = pkgs.trayscale;
      # extraArgs = ["--hide-window"];
    })
  ];
}
