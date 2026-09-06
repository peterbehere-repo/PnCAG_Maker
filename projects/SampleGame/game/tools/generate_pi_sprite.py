from pathlib import Path

from PIL import Image, ImageDraw


FRAME_WIDTH = 96
FRAME_HEIGHT = 112
OUTPUT = Path("/home/peterbehere1/sample-game/assets/sprites/pi/pi_idle.png")

COLORS = {
    "clear": (0, 0, 0, 0),
    "outline": (18, 18, 26, 255),
    "coat": (67, 48, 42, 255),
    "coat_light": (104, 75, 55, 255),
    "coat_shadow": (42, 39, 47, 255),
    "shirt": (169, 174, 177, 255),
    "skin": (183, 131, 96, 255),
    "skin_light": (220, 163, 116, 255),
    "hat": (55, 39, 32, 255),
    "hat_light": (102, 67, 42, 255),
    "hair": (30, 25, 25, 255),
    "jeans": (37, 46, 57, 255),
    "shoe": (39, 30, 28, 255),
    "cyan": (75, 224, 220, 255),
    "cyan_dark": (32, 105, 117, 255),
    "desk": (82, 51, 38, 255),
}


def rect(draw, box, color):
    draw.rectangle(box, fill=COLORS[color])


def draw_frame(image, frame_index, pose):
    draw = ImageDraw.Draw(image)
    left = frame_index * FRAME_WIDTH
    x = left + 45
    head_y = 19
    lean = {"typing": 0, "back": 4, "sigh": 2}[pose]

    # Chair back and seated silhouette.
    rect(draw, (left + 20, 42, left + 42, 88), "outline")
    rect(draw, (left + 23, 45, left + 39, 84), "coat_shadow")
    rect(draw, (left + 16, 84, left + 70, 91), "outline")
    rect(draw, (left + 20, 86, left + 67, 88), "coat_shadow")

    # Fedora, head, neck, and face turned toward the desk.
    rect(draw, (x - 16 + lean, head_y + 8, x + 12 + lean, head_y + 25), "skin")
    rect(draw, (x - 17 + lean, head_y + 6, x + 14 + lean, head_y + 10), "hat")
    rect(draw, (x - 10 + lean, head_y, x + 9 + lean, head_y + 7), "hat")
    rect(draw, (x - 7 + lean, head_y + 2, x + 7 + lean, head_y + 4), "hat_light")
    rect(draw, (x - 15 + lean, head_y + 14, x - 11 + lean, head_y + 17), "hair")
    rect(draw, (x + 8 + lean, head_y + 15, x + 11 + lean, head_y + 18), "hair")
    rect(draw, (x + 8 + lean, head_y + 20, x + 12 + lean, head_y + 22), "skin_light")
    rect(draw, (x - 2 + lean, head_y + 23, x + 3 + lean, head_y + 28), "shirt")

    # Trench coat and lapels.
    rect(draw, (x - 15 + lean, 47, x + 17 + lean, 82), "coat")
    rect(draw, (x - 11 + lean, 48, x - 2 + lean, 73), "coat_light")
    rect(draw, (x + 2 + lean, 48, x + 12 + lean, 74), "coat_shadow")
    rect(draw, (x - 4 + lean, 48, x + 2 + lean, 75), "shirt")
    rect(draw, (x - 1 + lean, 53, x + 2 + lean, 64), "hat_light")

    # Bent legs under the desk.
    rect(draw, (x - 10 + lean, 77, x + 3 + lean, 96), "jeans")
    rect(draw, (x + 4 + lean, 77, x + 17 + lean, 94), "jeans")
    rect(draw, (x - 15 + lean, 94, x + 3 + lean, 100), "shoe")
    rect(draw, (x + 13 + lean, 92, x + 26 + lean, 98), "shoe")

    # Desk edge, keyboard, terminal glow, and typing hands.
    rect(draw, (left + 6, 66, left + 89, 73), "outline")
    rect(draw, (left + 8, 68, left + 87, 71), "desk")
    rect(draw, (left + 35, 50, left + 66, 66), "outline")
    rect(draw, (left + 38, 52, left + 63, 63), "cyan_dark")
    rect(draw, (left + 40, 54, left + 61, 55), "cyan")
    rect(draw, (left + 40, 58, left + 57, 59), "cyan")

    if pose == "typing":
        hand_y = 64 + (frame_index % 2) * 2
        rect(draw, (x - 21 + lean, hand_y, x - 9 + lean, hand_y + 4), "skin_light")
        rect(draw, (x + 8 + lean, hand_y + 2, x + 20 + lean, hand_y + 5), "skin_light")
    elif pose == "back":
        rect(draw, (x - 20 + lean, 57, x - 11 + lean, 68), "coat_light")
        rect(draw, (x + 13 + lean, 57, x + 22 + lean, 68), "coat_light")
    else:
        rect(draw, (x - 18 + lean, 59, x - 9 + lean, 69), "coat_light")
        rect(draw, (x + 11 + lean, 59, x + 20 + lean, 69), "coat_light")
        rect(draw, (x + 1 + lean, 33, x + 8 + lean, 37), "skin_light")

    # Pixel outline accents.
    draw.line((left + 20, 42, left + 20, 88), fill=COLORS["outline"], width=2)
    draw.line((left + 70, 84, left + 70, 91), fill=COLORS["outline"], width=2)


def main():
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image = Image.new("RGBA", (FRAME_WIDTH * 9, FRAME_HEIGHT), COLORS["clear"])
    for frame_index in range(3):
        draw_frame(image, frame_index, "typing")
    for frame_index in range(3, 6):
        draw_frame(image, frame_index, "back")
    for frame_index in range(6, 9):
        draw_frame(image, frame_index, "sigh")
    image.save(OUTPUT)


if __name__ == "__main__":
    main()