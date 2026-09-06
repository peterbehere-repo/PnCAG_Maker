#!/usr/bin/env python3
"""
Generate 12 16-bit style pixel-art character sprites for a sci-fi neo-noir detective agency.

Output:
- Individual PNG sprites: 32x48 each
- Contact sheet PNG for quick preview
"""

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

OUT_DIR = Path("/home/peterbehere1/sample-game/assets/sprites/neo_noir_detective")
W, H = 32, 48
SCALE = 6

PALETTE = {
    "bg": (0, 0, 0, 0),
    "skin_a": (233, 190, 157, 255),
    "skin_b": (198, 152, 118, 255),
    "skin_c": (120, 84, 66, 255),
    "coat_dark": (40, 50, 74, 255),
    "coat_light": (66, 81, 112, 255),
    "black": (18, 18, 26, 255),
    "gray": (96, 102, 124, 255),
    "white": (224, 226, 234, 255),
    "neon_cyan": (65, 214, 224, 255),
    "neon_magenta": (214, 78, 184, 255),
    "neon_lime": (170, 214, 48, 255),
    "red": (198, 54, 66, 255),
    "gold": (198, 160, 72, 255),
    "violet": (110, 86, 164, 255),
    "brown": (116, 80, 58, 255),
    "navy": (30, 38, 68, 255),
    "olive": (96, 110, 58, 255),
}

# name, role, skin, hair, coat, accent, accessory
CHARACTERS = [
    ("protagonist_private_eye", "protagonist", "skin_a", "black", "coat_dark", "neon_cyan", "fedora"),
    ("antagonist_corp_baron", "antagonist", "skin_b", "white", "black", "red", "visor"),
    ("android_partner", "ally", "gray", "gray", "navy", "neon_cyan", "optic"),
    ("street_informant", "support", "skin_c", "black", "brown", "neon_lime", "hood"),
    ("forensic_hacker", "support", "skin_a", "violet", "black", "neon_magenta", "goggles"),
    ("agency_chief", "support", "skin_b", "white", "coat_light", "gold", "badge"),
    ("cyber_doc", "support", "skin_c", "gray", "white", "neon_cyan", "mask"),
    ("bounty_hunter", "neutral", "skin_b", "black", "olive", "red", "pauldron"),
    ("undercover_cop", "ally", "skin_a", "brown", "coat_dark", "gold", "tie"),
    ("night_club_singer", "neutral", "skin_c", "neon_magenta", "black", "gold", "earpiece"),
    ("mechanic", "support", "skin_b", "brown", "gray", "neon_lime", "toolbelt"),
    ("rogue_ai_avatar", "antagonist", "gray", "neon_cyan", "black", "neon_magenta", "halo"),
]


def px(img, x, y, color):
    if 0 <= x < W and 0 <= y < H:
        img.putpixel((x, y), color)


def fill_rect(img, x0, y0, x1, y1, color):
    d = ImageDraw.Draw(img)
    d.rectangle([x0, y0, x1, y1], fill=color)


def outline_rect(img, x0, y0, x1, y1, color):
    d = ImageDraw.Draw(img)
    d.rectangle([x0, y0, x1, y1], outline=color)


def draw_head(img, skin_color, hair_color):
    fill_rect(img, 11, 5, 20, 15, skin_color)
    fill_rect(img, 11, 4, 20, 7, hair_color)
    px(img, 13, 10, PALETTE["black"])
    px(img, 18, 10, PALETTE["black"])
    px(img, 15, 13, PALETTE["red"])
    px(img, 16, 13, PALETTE["red"])


def draw_body(img, coat_color, accent_color):
    fill_rect(img, 9, 16, 22, 33, coat_color)
    fill_rect(img, 14, 18, 17, 33, PALETTE["black"])
    fill_rect(img, 9, 23, 11, 30, coat_color)
    fill_rect(img, 20, 23, 22, 30, coat_color)
    fill_rect(img, 8, 20, 9, 31, PALETTE["gray"])
    fill_rect(img, 22, 20, 23, 31, PALETTE["gray"])
    fill_rect(img, 12, 22, 13, 24, accent_color)
    fill_rect(img, 18, 22, 19, 24, accent_color)


def draw_legs(img):
    fill_rect(img, 11, 34, 14, 45, PALETTE["black"])
    fill_rect(img, 17, 34, 20, 45, PALETTE["black"])
    fill_rect(img, 10, 45, 15, 47, PALETTE["brown"])
    fill_rect(img, 16, 45, 21, 47, PALETTE["brown"])


def draw_accessory(img, accessory, accent_color):
    if accessory == "fedora":
        fill_rect(img, 10, 3, 21, 4, PALETTE["black"])
        fill_rect(img, 12, 1, 19, 3, PALETTE["black"])
        fill_rect(img, 14, 2, 17, 2, accent_color)
    elif accessory == "visor":
        fill_rect(img, 11, 9, 20, 11, accent_color)
        px(img, 10, 10, PALETTE["black"])
        px(img, 21, 10, PALETTE["black"])
    elif accessory == "optic":
        fill_rect(img, 12, 9, 14, 11, accent_color)
        fill_rect(img, 17, 9, 19, 11, accent_color)
        fill_rect(img, 15, 10, 16, 10, PALETTE["gray"])
    elif accessory == "hood":
        fill_rect(img, 9, 4, 22, 12, PALETTE["black"])
        fill_rect(img, 11, 7, 20, 14, PALETTE["skin_c"])
    elif accessory == "goggles":
        fill_rect(img, 12, 9, 14, 11, accent_color)
        fill_rect(img, 17, 9, 19, 11, accent_color)
        fill_rect(img, 11, 10, 20, 10, PALETTE["gray"])
    elif accessory == "badge":
        fill_rect(img, 18, 26, 19, 27, accent_color)
        fill_rect(img, 18, 28, 19, 28, PALETTE["white"])
    elif accessory == "mask":
        fill_rect(img, 12, 11, 19, 14, PALETTE["white"])
        px(img, 12, 12, accent_color)
        px(img, 19, 12, accent_color)
    elif accessory == "pauldron":
        fill_rect(img, 20, 18, 23, 21, accent_color)
        outline_rect(img, 20, 18, 23, 21, PALETTE["black"])
    elif accessory == "tie":
        fill_rect(img, 15, 19, 16, 26, accent_color)
        fill_rect(img, 14, 20, 17, 21, PALETTE["white"])
    elif accessory == "earpiece":
        px(img, 21, 11, accent_color)
        fill_rect(img, 20, 12, 21, 13, PALETTE["gray"])
    elif accessory == "toolbelt":
        fill_rect(img, 10, 31, 21, 32, PALETTE["brown"])
        px(img, 12, 31, accent_color)
        px(img, 16, 32, accent_color)
        px(img, 19, 31, accent_color)
    elif accessory == "halo":
        outline_rect(img, 10, 2, 21, 5, accent_color)


def add_shading(img, coat_color):
    shade = tuple(max(c - 20, 0) for c in coat_color[:3]) + (255,)
    for y in range(16, 34):
        px(img, 9, y, shade)
        px(img, 22, y, shade)
    for y in range(5, 16):
        px(img, 11, y, PALETTE["skin_b"])


def create_sprite(name, skin_key, hair_key, coat_key, accent_key, accessory):
    img = Image.new("RGBA", (W, H), PALETTE["bg"])
    skin = PALETTE[skin_key]
    hair = PALETTE[hair_key]
    coat = PALETTE[coat_key]
    accent = PALETTE[accent_key]

    draw_head(img, skin, hair)
    draw_body(img, coat, accent)
    draw_legs(img)
    draw_accessory(img, accessory, accent)
    add_shading(img, coat)

    # Global outline pass for 16-bit readability on varied backgrounds.
    d = ImageDraw.Draw(img)
    d.rectangle([8, 4, 23, 47], outline=PALETTE["black"])

    out = OUT_DIR / f"{name}.png"
    img.save(out)
    return img


def fit_label_lines(name, max_chars=10):
    tokens = [token for token in name.replace("-", "_").split("_") if token]
    if not tokens:
        return [name[:max_chars]]

    lines = []
    current = ""
    for token in tokens:
        if not current:
            current = token
        elif len(current) + 1 + len(token) <= max_chars:
            current = f"{current}_{token}"
        else:
            lines.append(current)
            current = token
    if current:
        lines.append(current)

    if not lines:
        return [name[:max_chars]]

    final = []
    for line in lines:
        if len(line) <= max_chars:
            final.append(line)
            continue
        for i in range(0, len(line), max_chars):
            final.append(line[i : i + max_chars])

    return final[:3]


def scale_image(img, scale_factor):
    if scale_factor == 1.0:
        return img
    if scale_factor <= 0:
        raise ValueError(f"scale factor must be > 0, got {scale_factor}")

    size = (max(1, int(img.width * scale_factor)), max(1, int(img.height * scale_factor)))
    return img.resize(size, resample=Image.NEAREST)


def convert_to_bit_depth(img, bit_depth):
    if bit_depth == "24bit":
        return img.convert("RGBA")
    if bit_depth == "16bit":
        rgb = img.convert("RGB")
        out = Image.new("RGB", rgb.size)
        pixels = out.load()
        for y in range(rgb.height):
            for x in range(rgb.width):
                r, g, b = rgb.getpixel((x, y))
                r16 = (r >> 3) << 3
                g16 = (g >> 2) << 2
                b16 = (b >> 3) << 3
                pixels[x, y] = (r16, g16, b16)
        return out.convert("RGBA")
    if bit_depth == "256color":
        rgb = img.convert("RGB")
        quantized = rgb.quantize(colors=256, method=Image.MEDIANCUT)
        return quantized.convert("RGBA")
    raise ValueError(f"Unsupported bit depth: {bit_depth}")


def export_scaled_variant(name, sprite, scale_factor, bit_depth, output_dir):
    scaled = scale_image(sprite, scale_factor)
    safely_converted = convert_to_bit_depth(scaled, bit_depth)
    stem = f"{name}_{bit_depth.lower()}_{scale_factor:g}x"
    output_path = output_dir / f"{stem}.png"
    safely_converted.save(output_path)
    return output_path


def create_contact_sheet(sprites, scale_factor=1.0, bit_depth="24bit"):
    cols = 4
    rows = 3
    pad = 4
    label_font = ImageFont.load_default()
    max_label_lines = max(
        len(fit_label_lines(name, max_chars=10)) for name, _ in sprites
    )
    line_h = 10
    label_h = max(14, 6 + max_label_lines * line_h)
    base_w = W * int(scale_factor)
    base_h = H * int(scale_factor)
    sheet_w = cols * (base_w + pad) + pad
    sheet_h = rows * (base_h + label_h + pad) + pad

    sheet = Image.new("RGBA", (sheet_w, sheet_h), (12, 13, 18, 255))
    d = ImageDraw.Draw(sheet)

    for idx, (name, sprite) in enumerate(sprites):
        scaled_sprite = scale_image(sprite, scale_factor)
        r = idx // cols
        c = idx % cols
        x = pad + c * (base_w + pad)
        y = pad + r * (base_h + label_h + pad)
        sheet.alpha_composite(convert_to_bit_depth(scaled_sprite, bit_depth), (x, y))

        label_lines = fit_label_lines(name, max_chars=10)
        label_top = y + base_h + 2
        for line_idx, line in enumerate(label_lines):
            line_x = x + 2
            line_y = label_top + line_idx * (line_h + 1)
            d.text((line_x, line_y), line, font=label_font, fill=(210, 214, 228, 255))

    sheet.save(OUT_DIR / f"_contact_sheet_{bit_depth.lower()}_{scale_factor:g}x.png")
    if scale_factor == 1.0:
        sheet.save(OUT_DIR / "_contact_sheet.png")


def parse_args():
    parser = argparse.ArgumentParser(description="Generate neo-noir sprite assets with scale and color-depth options.")
    parser.add_argument("--scale", type=float, default=1.0, help="Scale factor for sprites and contact-sheet previews (1.0 is native size).")
    parser.add_argument(
        "--bit-depth",
        choices=["24bit", "16bit", "256color"],
        default="24bit",
        help="Output color depth for generated images.",
    )
    parser.add_argument("--output-dir", type=Path, default=OUT_DIR, help="Directory for exported sprite assets.")
    return parser.parse_args()


def main():
    args = parse_args()
    output_dir = args.output_dir
    output_dir.mkdir(parents=True, exist_ok=True)
    created = []

    for name, _role, skin, hair, coat, accent, accessory in CHARACTERS:
        sprite = create_sprite(name, skin, hair, coat, accent, accessory)
        created.append((name, sprite))
        export_scaled_variant(name, sprite, args.scale, args.bit_depth, output_dir)

    create_contact_sheet(created, scale_factor=args.scale, bit_depth=args.bit_depth)

    manifest = output_dir / "manifest.txt"
    with manifest.open("w", encoding="utf-8") as f:
        f.write(f"Neo-noir detective character sprites ({args.bit_depth}, scale {args.scale:g}x)\n")
        for name, role, *_rest in CHARACTERS:
            f.write(f"- {name}: {role}\n")

    print(f"Created {len(created)} sprites in {output_dir} with {args.bit_depth} and {args.scale:g}x scaling")


if __name__ == "__main__":
    main()
