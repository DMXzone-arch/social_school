#!/usr/bin/env python3
"""Generates the bundled opportunity artwork used by the home-feed stories
strip (assets/opportunities/<category>.jpg).

All art is drawn offline with PIL from geometric primitives - no network,
no stock photos - so the demo stays fully self-contained. Re-run after
brand changes:

    python3 tool/gen_opportunity_art.py
"""
from PIL import Image, ImageDraw, ImageFilter
import math
import os

SIZE = (472, 672)  # 4x the on-screen tile (118x168 dp)
OUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'opportunities')

WHITE = (255, 255, 255, 235)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def gradient(colors, size=SIZE):
    """Diagonal multi-stop gradient."""
    w, h = size
    img = Image.new('RGB', size)
    px = img.load()
    diag = (w - 1) + (h - 1)
    for y in range(h):
        for x in range(0, w, 2):
            t = (x + y) / diag
            seg = t * (len(colors) - 1)
            i = min(int(seg), len(colors) - 2)
            c = lerp(colors[i], colors[i + 1], seg - i)
            px[x, y] = c
            if x + 1 < w:
                px[x + 1, y] = c
    return img.convert('RGBA')


def add_bokeh(img, seed):
    """Soft translucent circles for depth."""
    overlay = Image.new('RGBA', img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    rnd = seed
    for _ in range(7):
        rnd = (rnd * 1103515245 + 12345) % (2 ** 31)
        cx = rnd % img.width
        rnd = (rnd * 1103515245 + 12345) % (2 ** 31)
        cy = rnd % img.height
        rnd = (rnd * 1103515245 + 12345) % (2 ** 31)
        r = 30 + rnd % 90
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 255, 255, 16))
    overlay = overlay.filter(ImageFilter.GaussianBlur(6))
    return Image.alpha_composite(img, overlay)


def add_light_rays(img):
    """Diagonal light beam from the top-left corner."""
    overlay = Image.new('RGBA', img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    d.polygon([(-40, -20), (220, -20), (-20, 420), (-160, 180)],
              fill=(255, 255, 255, 26))
    overlay = overlay.filter(ImageFilter.GaussianBlur(18))
    return Image.alpha_composite(img, overlay)


def add_scrim(img):
    """Dark gradient over the bottom half so overlaid white text reads well."""
    w, h = img.size
    overlay = Image.new('RGBA', img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    for y in range(h // 2, h):
        t = (y - h // 2) / (h // 2)
        d.line([(0, y), (w, y)], fill=(0, 0, 0, int(12 + 96 * t * t)))
    return Image.alpha_composite(img, overlay)


def canvas(seed):
    return Image.new('RGBA', SIZE, (0, 0, 0, 0))


# ---------------------------------------------------------------------------
# Category artwork - each returns an RGBA overlay with the white line-art icon
# ---------------------------------------------------------------------------

def art_scholarship():
    im = canvas(0)
    d = ImageDraw.Draw(im)
    cx, cy = SIZE[0] // 2, SIZE[1] // 2 - 40
    # Cap crown (diamond)
    d.polygon([(cx, cy - 78), (cx - 100, cy - 38), (cx, cy + 2), (cx + 100, cy - 38)],
              outline=WHITE, width=11)
    # Base under the crown
    d.polygon([(cx - 58, cy - 4), (cx + 58, cy - 4), (cx + 40, cy + 58), (cx - 40, cy + 58)],
              outline=WHITE, width=11)
    # Tassel
    d.line([(cx + 100, cy - 38), (cx + 100, cy + 30)], fill=WHITE, width=9)
    d.ellipse([cx + 90, cy + 30, cx + 110, cy + 50], fill=WHITE)
    return im


def art_internship():
    im = canvas(0)
    d = ImageDraw.Draw(im)
    cx, cy = SIZE[0] // 2, SIZE[1] // 2
    # Case body
    d.rounded_rectangle([cx - 92, cy - 32, cx + 92, cy + 62], radius=16,
                        outline=WHITE, width=11)
    # Handle
    d.arc([cx - 36, cy - 66, cx + 36, cy - 14], 180, 360, fill=WHITE, width=10)
    # Band + clasp
    d.line([(cx - 92, cy + 12), (cx + 92, cy + 12)], fill=WHITE, width=7)
    d.rounded_rectangle([cx - 16, cy + 0, cx + 16, cy + 24], radius=5, fill=WHITE)
    return im


def art_competition():
    im = canvas(0)
    d = ImageDraw.Draw(im)
    cx, cy = SIZE[0] // 2, SIZE[1] // 2 - 20
    # Cup bowl: rim + converging sides + rounded bottom arc
    d.line([(cx - 58, cy - 62), (cx + 58, cy - 62)], fill=WHITE, width=10)
    d.line([(cx - 58, cy - 62), (cx - 40, cy - 8)], fill=WHITE, width=10)
    d.line([(cx + 58, cy - 62), (cx + 40, cy - 8)], fill=WHITE, width=10)
    d.arc([cx - 40, cy - 40, cx + 40, cy + 28], 0, 180, fill=WHITE, width=10)
    # Handles
    d.arc([cx - 104, cy - 66, cx - 40, cy - 4], 100, 290, fill=WHITE, width=9)
    d.arc([cx + 40, cy - 66, cx + 104, cy - 4], 250, 80, fill=WHITE, width=9)
    # Stem + base
    d.line([(cx, cy + 20), (cx, cy + 56)], fill=WHITE, width=12)
    d.rounded_rectangle([cx - 48, cy + 56, cx + 48, cy + 84], radius=8, fill=WHITE)
    return im


def art_training():
    im = canvas(0)
    d = ImageDraw.Draw(im)
    cx, cy = SIZE[0] // 2, SIZE[1] // 2 + 10
    # Ribbon tails
    d.polygon([(cx - 46, cy - 70), (cx - 18, cy - 150), (cx, cy - 118), (cx + 18, cy - 150),
               (cx + 46, cy - 70)], outline=WHITE, width=9)
    # Medal disc
    d.ellipse([cx - 66, cy - 76, cx + 66, cy + 56], outline=WHITE, width=11)
    # Star inside
    pts = []
    for i in range(10):
        ang = -math.pi / 2 + i * math.pi / 5
        r = 40 if i % 2 == 0 else 17
        pts.append((cx + r * math.cos(ang), cy - 10 + r * math.sin(ang)))
    d.polygon(pts, fill=WHITE)
    return im


def art_conference():
    im = canvas(0)
    d = ImageDraw.Draw(im)
    cx, cy = SIZE[0] // 2, SIZE[1] // 2
    # Side people
    for dx in (-72, 72):
        d.ellipse([cx + dx - 24, cy - 58, cx + dx + 24, cy - 10], outline=WHITE, width=9)
        d.pieslice([cx + dx - 44, cy - 16, cx + dx + 44, cy + 74], 180, 360,
                   outline=WHITE, width=9)
    # Centre person (front)
    d.ellipse([cx - 30, cy - 78, cx + 30, cy - 18], fill=WHITE)
    d.pieslice([cx - 54, cy - 8, cx + 54, cy + 92], 180, 360, fill=WHITE)
    return im


def art_youth():
    im = canvas(0)
    d = ImageDraw.Draw(im)
    cx, cy = SIZE[0] // 2, SIZE[1] // 2 + 30
    # Pot
    d.polygon([(cx - 62, cy + 6), (cx + 62, cy + 6), (cx + 44, cy + 78), (cx - 44, cy + 78)],
              outline=WHITE, width=10)
    d.rounded_rectangle([cx - 72, cy - 16, cx + 72, cy + 12], radius=8, outline=WHITE, width=10)
    # Stem
    d.line([(cx, cy - 16), (cx, cy - 110)], fill=WHITE, width=10)
    # Leaves (rotated ellipses)
    leaf = Image.new('RGBA', (120, 64), (0, 0, 0, 0))
    ImageDraw.Draw(leaf).ellipse([0, 0, 119, 63], outline=WHITE, width=9)
    left = leaf.rotate(28, expand=True, resample=Image.BICUBIC)
    right = leaf.rotate(-28, expand=True, resample=Image.BICUBIC)
    im.alpha_composite(left, (cx - 128, cy - 140))
    im.alpha_composite(right, (cx + 8, cy - 140))
    return im


CATEGORIES = {
    'scholarship': ([(11, 45, 90), (23, 105, 170), (80, 180, 235)], art_scholarship, 7),
    'internship': ([(8, 74, 66), (22, 160, 133), (90, 210, 190)], art_internship, 13),
    'competition': ([(122, 79, 12), (244, 185, 66), (252, 216, 130)], art_competition, 29),
    'training': ([(56, 31, 130), (109, 40, 217), (170, 140, 250)], art_training, 41),
    'conference': ([(10, 58, 92), (3, 105, 161), (80, 180, 235)], art_conference, 53),
    'youth': ([(17, 74, 40), (21, 128, 61), (100, 220, 130)], art_youth, 67),
}


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for name, (colors, art_fn, seed) in CATEGORIES.items():
        img = gradient(colors)
        img = add_light_rays(img)
        img = add_bokeh(img, seed)
        img.alpha_composite(art_fn())
        img = add_scrim(img)
        path = os.path.join(OUT_DIR, f'{name}.jpg')
        img.convert('RGB').save(path, 'JPEG', quality=85, optimize=True)
        print(f'wrote {path}')


if __name__ == '__main__':
    main()
