from pathlib import Path

from PIL import Image, ImageDraw


SOURCE = Path("/home/peterbehere1/sample-game/assets/concept_art/sample office scene.png")
OUTPUT = Path("/home/peterbehere1/sample-game/assets/art/desk_foreground.png")


def main() -> None:
    image = Image.open(SOURCE).convert("RGBA")
    mask = Image.new("L", image.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.polygon([(330, 470), (1085, 470), (1145, 768), (285, 768)], fill=255)
    image.putalpha(mask)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image.save(OUTPUT)


if __name__ == "__main__":
    main()