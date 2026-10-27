"""Frames the raw renders from render.sh for the README and the website.

Usage: python3 -I tool/snapshots/compose.py <raw dir> <out dir> [overview]

Writes preview.png and preview-dark.png (a laptop and a phone in opposite
themes on a transparent 2400x1500 canvas, as site/index.html declares) and one framed WebP per
screen and theme under screens/.
"""

import subprocess
import sys
from functools import cache
from math import cos, pi, sin
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

SS = 4  # supersampling for antialiased shapes
THEMES = ('light', 'dark')
OTHER = {'light': 'dark', 'dark': 'light'}

SCREENS = {
    'desktop-dashboard': 'macos-dashboard-detailed',
    'desktop-proxies': 'macos-proxies-detailed',
    'desktop-profiles': 'macos-profiles-detailed',
    'desktop-connections': 'macos-connections-detailed',
    'mobile-dashboard': 'android-dashboard-simple',
    'mobile-proxies': 'android-proxies-simple',
    'mobile-profiles': 'android-profiles-simple',
}

# Wallpaper corners: top left, top right, bottom left, bottom right.
WALLPAPER = {
    'light': ((160, 186, 250), (238, 188, 226), (194, 168, 246), (252, 208, 172)),
    'dark': ((32, 46, 116), (96, 36, 102), (46, 32, 108), (146, 76, 30)),
}
MENU_BAR = {'light': ((255, 255, 255, 96), (24, 24, 26)), 'dark': ((0, 0, 0, 90), (240, 240, 244))}
ALUMINIUM = {'light': ((228, 229, 232), (168, 170, 175)), 'dark': ((122, 123, 128), (62, 63, 67))}
OUTLINE = {'light': (0, 0, 0, 46), 'dark': (255, 255, 255, 40)}
TRAFFIC = ((255, 95, 87), (254, 188, 46), (40, 200, 64))
GLASS = (8, 8, 9, 255)
PHONE_LIGHT = (0.6, -0.8)


def raw_shot(raw, name, theme):
    shots = sorted((raw / name).glob(f'*_{theme}_*.png'))
    if not shots:
        sys.exit(f'missing render: {raw / name} ({theme}); run render.sh first')
    return Image.open(shots[0]).convert('RGBA')


@cache
def font(size, weight='medium'):
    try:
        path = subprocess.run(
            ['fc-match', '-f', '%{file}', f'Roboto:{weight}'],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
        return ImageFont.truetype(path, size)
    except (OSError, subprocess.CalledProcessError):
        return ImageFont.load_default(size)


def squircle_mask(size, radius):
    """A continuous-corner mask, close to the app's superellipse corners."""
    w, h = size
    big = Image.new('L', (w * SS, h * SS), 0)
    r = radius * SS
    draw = ImageDraw.Draw(big)
    draw.rectangle((r, 0, w * SS - r, h * SS), fill=255)
    draw.rectangle((0, r, w * SS, h * SS - r), fill=255)
    n = 5.0
    steps = 90
    for cx, cy, sx, sy in (
        (r, r, -1, -1),
        (w * SS - r, r, 1, -1),
        (r, h * SS - r, -1, 1),
        (w * SS - r, h * SS - r, 1, 1),
    ):
        points = [(cx, cy)]
        for i in range(steps + 1):
            t = i / steps * pi / 2
            x = abs(cos(t)) ** (2 / n) * r
            y = abs(sin(t)) ** (2 / n) * r
            points.append((cx + sx * x, cy + sy * y))
        draw.polygon(points, fill=255)
    return big.resize(size, Image.LANCZOS)


def top_rounded_mask(size, radius):
    w, h = size
    return squircle_mask((w, h + 2 * radius), radius).crop((0, 0, w, h))


def masked(image, mask):
    out = image.copy()
    out.putalpha(ImageChops.multiply(out.getchannel('A'), mask))
    return out


def rounded(image, radius):
    return masked(image, squircle_mask(image.size, radius))


def outlined(image, radius, color, width=2):
    """Pads image with a hairline ring drawn just outside its corners."""
    w, h = image.size
    pad = width
    ring = Image.new('RGBA', (w + 2 * pad, h + 2 * pad), color)
    ring = rounded(ring, radius + pad)
    ring.alpha_composite(rounded(image, radius), (pad, pad))
    return ring


def vertical_gradient(size, top, bottom):
    mask = Image.linear_gradient('L').resize(size)
    return Image.composite(Image.new('RGBA', size, bottom + (255,)), Image.new('RGBA', size, top + (255,)), mask)


def four_corner(size, corners):
    """A smooth wallpaper blended from four corner colours."""
    seed = Image.new('RGB', (2, 2))
    seed.putdata(list(corners))
    return seed.resize(size, Image.BILINEAR).convert('RGBA')


def shadow(canvas, image, pos, blur, offset, opacity):
    """Drops a soft shadow of image's silhouette onto canvas."""
    pad = blur * 3
    alpha = image.getchannel('A').point(lambda a: int(a * opacity))
    sil = Image.new('L', (image.width + 2 * pad, image.height + 2 * pad), 0)
    sil.paste(alpha, (pad, pad))
    layer = Image.new('RGBA', sil.size, (0, 0, 0, 255))
    layer.putalpha(sil.filter(ImageFilter.GaussianBlur(blur)))
    canvas.alpha_composite(layer, (pos[0] - pad + offset[0], pos[1] - pad + offset[1]))


def traffic_lights(image, scale):
    """Paints macOS window buttons where a hidden title bar keeps them."""
    big = Image.new('RGBA', (image.width * SS, round(40 * scale) * SS), (0, 0, 0, 0))
    draw = ImageDraw.Draw(big)
    r = 6 * scale * SS
    for i, color in enumerate(TRAFFIC):
        cx, cy = (20 + 20 * i) * scale * SS, 18 * scale * SS
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=tuple(int(c * 0.82) for c in color))
        inner = r - 0.7 * scale * SS
        draw.ellipse((cx - inner, cy - inner, cx + inner, cy + inner), fill=color)
    image.alpha_composite(big.resize((image.width, round(40 * scale)), Image.LANCZOS))


def mac_window(screen, width, theme):
    scale = width / 1280
    screen = screen.resize((width, round(screen.height * width / screen.width)), Image.LANCZOS)
    traffic_lights(screen, scale)
    return outlined(screen, round(24 * scale), OUTLINE[theme], width=max(1, round(scale)))


def wifi(draw, cx, base, size, ink, width):
    for k in (1.0, 0.64):
        r = size * k
        draw.arc((cx - r, base - r, cx + r, base + r), 225, 315, fill=ink, width=width)
    r = size * 0.3
    draw.pieslice((cx - r, base - r, cx + r, base + r), 225, 315, fill=ink)


def battery(draw, right, mid, scale, ink, level=0.8):
    """Draws a battery ending at right and returns its left edge."""
    bw, bh = 25 * scale, 12 * scale
    left = right - bw
    body = right - 2.5 * scale
    draw.rounded_rectangle((left, mid - bh / 2, body, mid + bh / 2), radius=3.5 * scale, outline=ink, width=max(1, round(1.2 * scale)))
    draw.rounded_rectangle((right - 1.8 * scale, mid - 2.5 * scale, right, mid + 2.5 * scale), radius=1 * scale, fill=ink)
    inset = 2.2 * scale
    level_right = left + inset + (body - left - 2 * inset) * level
    draw.rounded_rectangle((left + inset, mid - bh / 2 + inset, level_right, mid + bh / 2 - inset), radius=1.8 * scale, fill=ink)
    return left


def status_bar(screen, scale, dark):
    """Paints an Android status bar into the 36 dp inset render.sh leaves."""
    s = scale * 2
    band = 36 * scale
    big = Image.new('RGBA', (screen.width * 2, band * 2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(big)
    ink = (240, 238, 236) if dark else (28, 27, 26)
    mid = 18 * s
    draw.text((28 * s, mid), '9:41', font=font(int(15 * s), 'bold'), fill=ink, anchor='lm')
    x = battery(draw, big.width - 26 * s, mid, s, ink) - 16 * s
    wifi(draw, x, mid + 6 * s, 11 * s, ink, max(1, round(2.4 * s)))
    x -= 20 * s
    for i in range(4):
        h = (4 + 2.4 * i) * s
        right = x - (3 - i) * 4.6 * s
        draw.rounded_rectangle((right - 3 * s, mid + 5 * s - h, right, mid + 5 * s), radius=0.8 * s, fill=ink)
    cx = big.width / 2
    for r, fill in ((6, (6, 6, 7)), (3.4, (20, 22, 30)), (1.6, (10, 10, 14))):
        draw.ellipse((cx - r * s, mid - r * s, cx + r * s, mid + r * s), fill=fill)
    draw.ellipse((cx - 2.6 * s, mid - 2.6 * s, cx - 1.2 * s, mid - 1.2 * s), fill=(78, 86, 118))
    screen.alpha_composite(big.resize((screen.width, band), Image.LANCZOS))
    draw = ImageDraw.Draw(screen)
    pill = 108 * scale
    draw.rounded_rectangle(
        (screen.width / 2 - pill / 2, screen.height - 9 * scale, screen.width / 2 + pill / 2, screen.height - 5 * scale),
        radius=2 * scale,
        fill=ink,
    )


def box_distance(size, box, radius):
    """Signed distance in pixels to a round-cornered box, negative inside."""
    x0, y0, x1, y1 = box
    ys, xs = np.mgrid[0 : size[1], 0 : size[0]].astype(np.float32) + 0.5
    qx = np.abs(xs - (x0 + x1) / 2) - ((x1 - x0) / 2 - radius)
    qy = np.abs(ys - (y0 + y1) / 2) - ((y1 - y0) / 2 - radius)
    return np.hypot(np.maximum(qx, 0), np.maximum(qy, 0)) + np.minimum(np.maximum(qx, qy), 0) - radius


def inside(depth, edge):
    """Coverage of the band deeper than edge, antialiased over one pixel."""
    return np.clip(depth - edge + 0.5, 0, 1)


def metal(distance, sheen):
    """Graphite shaded by how its outward normal faces the light, brightest at the edge."""
    gy, gx = np.gradient(distance)
    lit = (gx * PHONE_LIGHT[0] + gy * PHONE_LIGHT[1]) / (np.hypot(gx, gy) + 1e-6)
    edge = np.exp(np.minimum(distance, 0) / sheen)
    return 46 + 12 * lit + 44 * edge * (0.6 + 0.4 * lit)


def phone(screen, width, theme):
    """A graphite phone around a render, scaled to width, its side keys included."""
    screen = screen.copy()
    status_bar(screen, round(screen.width / 412), theme == 'dark')
    frame = round(width * 0.04)
    inner = width - 2 * frame
    screen = screen.resize((inner, round(screen.height * inner / screen.width)), Image.LANCZOS)
    height = screen.height + 2 * frame
    left, right = max(2, round(width * 0.007)), max(2, round(width * 0.01))
    size = (left + width + right, height)

    body = box_distance(size, (left, 0, left + width, height), width * 0.145)
    depth = -body
    rim, groove, line = width * 0.0072, width * 0.004, width * 0.0035
    fall = np.linspace(1, 0, height, dtype=np.float32)[:, None]
    bezel = 29 + 9 * fall - 14 * np.exp(-np.maximum(depth - rim - groove, 0) / (width * 0.003))
    tone = metal(body, width * 0.003)
    tone += (8 - tone) * inside(depth, rim)
    tone += (bezel - tone) * inside(depth, rim + groove)
    tone += (12 - tone) * inside(depth, frame - line)
    alpha = np.clip(depth + 0.5, 0, 1)

    keys = [((0, 4 * left), span, left) for span in ((0.179, 0.224), (0.255, 0.343), (0.361, 0.447))]
    keys.append(((size[0] - 4 * right, size[0]), (0.281, 0.413), right))
    sides = np.minimum.reduce(
        [box_distance(size, (x0, height * top, x1, height * bottom), w * 1.2) for (x0, x1), (top, bottom), w in keys],
    )
    side_alpha = np.clip(0.5 - sides, 0, 1) * (1 - alpha)
    tone = tone * alpha + metal(sides, right * 0.5) * side_alpha
    alpha += side_alpha
    tone /= np.maximum(alpha, 1e-6)

    rgba = np.stack((tone, tone, tone * 1.05 + 1, alpha * 255), axis=-1)
    out = Image.fromarray(np.clip(rgba + 0.5, 0, 255).astype(np.uint8), 'RGBA')
    glass = np.clip(0.5 - (body + frame), 0, 1)[frame : height - frame, left + frame : left + width - frame]
    out.alpha_composite(masked(screen, Image.fromarray((glass * 255 + 0.5).astype(np.uint8), 'L')), (left + frame, frame))
    return out


def menu_bar(screen, height, theme):
    fill, ink = MENU_BAR[theme]
    screen.alpha_composite(Image.new('RGBA', (screen.width, height), fill))
    draw = ImageDraw.Draw(screen)
    mid = height / 2
    x = 34
    for i, label in enumerate(('ReClash', 'File', 'Edit', 'View', 'Window', 'Help')):
        f = font(21, 'bold' if i == 0 else 'regular')
        draw.text((x, mid), label, font=f, fill=ink, anchor='lm')
        x += draw.textlength(label, font=f) + 30
    clock = 'Tue Oct 27  9:41 AM'
    right = screen.width - 30
    draw.text((right, mid), clock, font=font(21, 'regular'), fill=ink, anchor='rm')
    right -= draw.textlength(clock, font=font(21, 'regular')) + 24
    right = battery(draw, right, mid, 1.15, ink) - 26
    wifi(draw, right, mid + 8, 15, ink, 3)
    notch_w, notch_h = round(screen.width * 0.13), height + 4
    cx = screen.width / 2
    draw.rounded_rectangle((cx - notch_w / 2, -20, cx + notch_w / 2, notch_h), radius=14, fill=GLASS)
    draw.ellipse((cx - 5, notch_h / 2 - 5, cx + 5, notch_h / 2 + 5), fill=(28, 30, 42))


def laptop(window, theme, width):
    """Returns a laptop lid showing window on a desktop, and its base."""
    edge, bezel, chin = 5, 28, 32
    sw = width - 2 * (edge + bezel)
    sh = round(sw / 1.52)
    lid_h = sh + edge + bezel + chin
    lid = masked(vertical_gradient((width, lid_h), *ALUMINIUM[theme]), top_rounded_mask((width, lid_h), 64))
    glass = Image.new('RGBA', (width - 2 * edge, lid_h - edge), GLASS)
    lid.alpha_composite(masked(glass, top_rounded_mask(glass.size, 60)), (edge, edge))

    screen = four_corner((sw, sh), WALLPAPER[theme])
    bar_h = round(sh * 0.036)
    menu_bar(screen, bar_h, theme)
    wx = (sw - window.width) // 2
    wy = bar_h + (sh - bar_h - window.height) // 2
    shadow(screen, window, (wx, wy), 26, (0, 22), 0.42)
    screen.alpha_composite(window, (wx, wy))
    lid.alpha_composite(masked(screen, top_rounded_mask(screen.size, 28)), (edge + bezel, edge + bezel))

    base_h, overhang = 44, 60
    top, bottom = ALUMINIUM[theme]
    base = vertical_gradient((width + 2 * overhang, base_h), top, bottom)
    mask = Image.new('L', (base.width * SS, base_h * SS), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, base.width * SS, base_h * SS), radius=base_h * SS * 0.5, fill=255)
    base.putalpha(mask.resize(base.size, Image.LANCZOS))
    draw = ImageDraw.Draw(base)
    draw.line((base_h / 2, 1, base.width - base_h / 2, 1), fill=tuple(min(255, c + 24) for c in top), width=2)
    draw.rounded_rectangle((base.width / 2 - 150, 0, base.width / 2 + 150, 10), radius=5, fill=tuple(int(c * 0.8) for c in bottom))
    return lid, base, overhang


def overview(raw, theme):
    canvas = Image.new('RGBA', (2400, 1500), (0, 0, 0, 0))
    window = mac_window(raw_shot(raw, SCREENS['desktop-dashboard'], theme), 1440, theme)
    lid, base, overhang = laptop(window, theme, 1770)
    lx, ly = 96, 56
    shadow(canvas, lid, (lx, ly), 30, (0, 24), 0.35)
    canvas.alpha_composite(lid, (lx, ly))
    bx, by = lx - overhang, ly + lid.height
    shadow(canvas, base, (bx, by), 18, (0, 16), 0.45)
    canvas.alpha_composite(base, (bx, by))

    other = OTHER[theme]
    handset = phone(raw_shot(raw, SCREENS['mobile-dashboard'], other), 520, other)
    px, py = 2400 - 54 - handset.width, 1500 - 34 - handset.height
    shadow(canvas, handset, (px, py), 34, (-10, 28), 0.55)
    canvas.alpha_composite(handset, (px, py))
    return canvas


def card(image, pad, blur, opacity):
    """Pads a framed render with a soft shadow on a transparent card."""
    out = Image.new('RGBA', (image.width + 2 * pad, image.height + 2 * pad), (0, 0, 0, 0))
    shadow(out, image, (pad, pad), blur, (0, blur // 2), opacity)
    out.alpha_composite(image, (pad, pad))
    return out


def main():
    raw, out = Path(sys.argv[1]), Path(sys.argv[2])
    (out / 'screens').mkdir(parents=True, exist_ok=True)
    only = sys.argv[3] if len(sys.argv) > 3 else None
    for theme in THEMES:
        suffix = '' if theme == 'light' else '-dark'
        overview(raw, theme).save(out / f'preview{suffix}.png', optimize=True)
        if only == 'overview':
            continue
        for name, source in SCREENS.items():
            shot = raw_shot(raw, source, theme)
            if name.startswith('desktop'):
                framed = card(mac_window(shot, 1600, theme), 48, 20, 0.32)
            else:
                framed = card(phone(shot, 640, theme), 40, 18, 0.4)
            framed.save(out / 'screens' / f'{name}-{theme}.webp', quality=88, method=6)
    print(f'wrote {out}/preview.png, {out}/preview-dark.png and {out}/screens/')


if __name__ == '__main__':
    main()
