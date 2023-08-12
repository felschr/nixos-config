{ lib, stdenv, fetchFromGitHub, cmake, zlib, cups, ... }:

# maintained fork of brlaser with newer drivers (including Brother HL-L2370DN)
stdenv.mkDerivation (finalAttrs: {
  pname = "brlaser";
  version = "6.2.6";

  src = fetchFromGitHub {
    owner = "Owl-Maintain";
    repo = "brlaser";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+W84s3Nulj0kz2h1WE7/QGysVylKkN/xNqcNvrQz6D8=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ zlib cups ];

  cmakeFlags = [ "-DCUPS_SERVER_BIN=lib/cups" "-DCUPS_DATA_DIR=share/cups" ];

  meta = with lib; {
    description = "A CUPS driver for Brother laser printers";
    longDescription = ''
      While most Brother printers can use standard printer languages like PCL or PostScript, some models do not. If you have a monochrome Brother laser printer (or multi-function device) and the other open-source drivers are not working, brlaser might be able to help. Additionally, there have been reports of some non-Brother printers working with this driver.

      The following printers have been reported to work with this driver:

          Brother DCP-1510 series
          Brother DCP-1600 series
          Brother DCP-1610W series
          Brother DCP-7020
          Brother DCP-7030
          Brother DCP-7040
          Brother DCP-7055
          Brother DCP-7055W
          Brother DCP-7060D
          Brother DCP-7065DN
          Brother DCP-7070DW
          Brother DCP-7080
          Brother DCP-7080D
          Brother DCP-8065DN
          Brother DCP-L2500D series
          Brother DCP-L2510D series
          Brother DCP-L2520D series
          Brother DCP-L2520DW series
          Brother DCP-L2537DW
          Brother DCP-L2540DW series
          Brother DCP-L2550DW series
          Brother FAX-2820
          Brother FAX-2840
          Brother HL-1110 series
          Brother HL-1200 series
          Brother HL-2030 series
          Brother HL-2130 series
          Brother HL-2140 series
          Brother HL-2220 series
          Brother HL-2230 series
          Brother HL-2240D series
          Brother HL-2250DN series
          Brother HL-2260
          Brother HL-2270DW series
          Brother HL-2280DW
          Brother HL-5030 series
          Brother HL-5040 series
          Brother HL-L2300D series
          Brother HL-L2305 series
          Brother HL-L2310D series
          Brother HL-L2320D series
          Brother HL-L2335D series
          Brother HL-L2340D series
          Brother HL-L2350DW series
          Brother HL-L2360D series
          Brother HL-L2370DN series
          Brother HL-L2375DW series
          Brother HL-L2380DW series
          Brother HL-L2390DW
          Brother HL-L5000D series
          Brother MFC-1810 series
          Brother MFC-1910W series
          Brother MFC-7240
          Brother MFC-7320
          Brother MFC-7340
          Brother MFC-7360N
          Brother MFC-7365DN
          Brother MFC-7420
          Brother MFC-7440N
          Brother MFC-7460DN
          Brother MFC-7860DW
          Brother MFC-8710DW
          Brother MFC-8860DN
          Brother MFC-9160
          Brother MFC-L2700DN series
          Brother MFC-L2700DW series
          Brother MFC-L2710DN series
          Brother MFC-L2710DW series
          Brother MFC-L2750DW series
          Fuji Xerox DocuPrint P265 dw
          Lenovo LJ2650DN
    '';
    homepage = "https://github.com/Owl-Maintain/brlaser";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ felschr ];
    changelog =
      "https://github.com/Owl-Maintain/brlaser/releases/tag/${finalAttrs.src.rStijnDWev}";
  };
})
