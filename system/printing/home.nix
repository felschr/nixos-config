{ pkgs, ... }:

{
  services.printing.drivers = with pkgs; [ brlaser ];

  hardware.printers = {
    ensureDefaultPrinter = "Brother_HL-L2370DN";
    ensurePrinters = [{
      name = "Brother_HL-L2370DN";
      description = "Brother HL-L2370DN";
      deviceUri =
        "dnssd://Brother%20HL-L2370DN%20series._ipp._tcp.local/?uuid=e3248000-80ce-11db-8000-b422007e1490";
      model = "drv:///brlaser.drv/brl2370d.ppd";
      # model = "everywhere";
    }];
  };
}
