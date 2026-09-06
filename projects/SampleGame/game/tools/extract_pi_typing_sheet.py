from pathlib import Path

from PIL import Image


SOURCE = Path("/home/peterbehere1/sample-game/assets/concept_art/sample anim_pi_idle_desk_sit_typing.png")
OUTPUT = Path("/home/peterbehere1/sample-game/assets/sprites/pi/pi_typing_32f.png")
CELL_WIDTH = 176
CELL_HEIGHT = 192
FRAME_WIDTH = 176
FRAME_HEIGHT = 192


def make_transparent(frame: Image.Image) -> Image.Image:
    pixels = frame.load()
    for y in range(frame.height):
        for x in range(frame.width):
            red, green, blue, _alpha = pixels[x, y]
            brightness = (red + green + blue) / 3
            saturation = max(red, green, blue) - min(red, green, blue)
            if y < 28 or (brightness > 48 and saturation < 24):
                pixels[x, y] = (red, green, blue, 0)
    return frame


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    sheet = Image.new("RGBA", (FRAME_WIDTH * 32, FRAME_HEIGHT), (0, 0, 0, 0))
    for frame_index in range(32):
        column = frame_index % 8
        row = frame_index // 8
        crop = source.crop((column * CELL_WIDTH, row * CELL_HEIGHT, (column + 1) * CELL_WIDTH, (row + 1) * CELL_HEIGHT))
        crop = make_transparent(crop)
        sheet.alpha_composite(crop, (frame_index * FRAME_WIDTH, 0))
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(OUTPUT)


if __name__ == "__main__":
    main()