# Generates badged application icons by overlaying a colored corner badge
# (circle with text or emoji) onto an existing icon.
#
# Base icons are looked up under `share/icons/hicolor/<size>x<size>/apps/${baseName}.png`
# and badged copies of the same sizes are installed as `${name}.png`.
{ pkgs }:
{
  pkg,
  baseName,
  name,
  badge,
}:
let
  badgeScript = pkgs.writeText "mkBadgedIcon.py" ''
    import glob
    import os
    import sys

    from PIL import Image, ImageDraw, ImageFont

    # Noto Color Emoji bitmap strike size.
    render_size = 109
    emoji_target = 0.64
    text_target = 0.46

    text = os.environ["badgeText"]
    color = os.environ["badgeColor"]
    base = os.environ["badgeBaseName"]
    name = os.environ["badgeName"]
    pkg_root = os.environ["badgePkgRoot"]
    out_dir = os.environ["out"]
    is_emoji = not text.isascii()

    def hex_rgb(value):
        h = value.lstrip("#")
        if len(h) == 3:
            h = "".join(c * 2 for c in h)
        return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))

    def render_glyph():
        canvas = Image.new("RGBA", (300, 300), (0, 0, 0, 0))
        draw = ImageDraw.Draw(canvas)
        if is_emoji:
            font = ImageFont.truetype(
                os.environ["badgeFontEmoji"], render_size
            )
            draw.text((150, 150), text, font=font, embedded_color=True, anchor="mm")
        else:
            font = ImageFont.truetype(
                os.environ["badgeFontSans"], render_size
            )
            draw.text(
                (150, 150), text, font=font, fill=hex_rgb(os.environ["badgeTextColor"]), anchor="mm"
            )
        return canvas.crop(canvas.getbbox())

    icons = sorted(
        glob.glob(pkg_root + "/share/icons/hicolor/*/apps/" + base + ".png")
    )
    if not icons:
        print(
            "mkBadgedIcon: no base icon '"
            + base
            + ".png' found in "
            + pkg_root
            + "/share/icons/hicolor/*/apps",
            file=sys.stderr,
        )
        sys.exit(1)

    glyph = render_glyph()

    for icon_path in icons:
        sizedir = os.path.basename(os.path.dirname(os.path.dirname(icon_path)))
        size = int(sizedir.split("x")[0])
        box = size * 42 // 100
        box -= box % 2
        inset = size * 5 // 100

        icon = Image.open(icon_path).convert("RGBA")
        badge_img = Image.new("RGBA", (box, box), (0, 0, 0, 0))
        ImageDraw.Draw(badge_img).ellipse(
            [0, 0, box - 1, box - 1], fill=hex_rgb(color) + (255,)
        )
        target_height = max(
            1, round(box * (emoji_target if is_emoji else text_target))
        )
        width = max(1, round(glyph.size[0] * target_height / glyph.size[1]))
        content = glyph.resize((width, target_height), Image.LANCZOS)
        badge_img.alpha_composite(
            content, ((box - content.size[0]) // 2, (box - content.size[1]) // 2)
        )
        icon.alpha_composite(
            badge_img, (icon.size[0] - box - inset, icon.size[1] - box - inset)
        )
        dest = "/".join(
            [out_dir, "share", "icons", "hicolor", sizedir, "apps", name + ".png"]
        )
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        icon.save(dest)
  '';
in
pkgs.runCommand "${name}-icon"
  {
    nativeBuildInputs = [ (pkgs.python3.withPackages (p: [ p.pillow ])) ];
    badgeBaseName = baseName;
    badgeColor = badge.color or "#2da44e";
    badgeFontEmoji = "${pkgs.noto-fonts-color-emoji}/share/fonts/noto/NotoColorEmoji.ttf";
    badgeFontSans = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans-Bold.ttf";
    badgeName = name;
    badgePkgRoot = pkg;
    badgeText = badge.text;
    badgeTextColor = badge.textColor or "#ffffff";
  }
  ''
    python3 ${badgeScript}
  ''
