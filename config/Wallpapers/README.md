# Wallpapers

Your personal wallpaper collection.

## What is versioned and what is not

This directory is **mostly ignored by git** on purpose: a wallpaper collection
weighs around 17 MB and should not be carried in the history of a dotfiles
repository. Only two files are versioned:

| File | Status | Reason |
| :--- | :--- | :--- |
| `default-wallpaper.jpg` | Versioned (211 KB) | Default background for `BackgroundShader.qml`. Without it, a fresh clone has nothing to display. |
| `README.md` | Versioned | This document. It keeps the directory present in the clone. |

Everything else you add here stays on your machine and **is not uploaded**. You
can download 4K wallpapers without worrying about the repository size.

## Add a wallpaper

Leave it in this directory under any name you prefer. There is no need to
register it anywhere: to use it, change `wallpaperSource` in
`config/quickshell/components/BackgroundShader.qml`:

```qml
property url wallpaperSource: Qt.resolvedUrl("../../Wallpapers/my-wallpaper.jpg")
```

Paths are relative to the QML file itself, so they work both from a local
checkout and from the installed theme. The CI portability check rejects
absolute paths.

## If the background is missing

`BackgroundShader.qml` draws a dark fallback gradient behind the image. If
`wallpaperSource` points to a nonexistent file, the greeter shows that
gradient instead of a black screen.

## Compress before using

A 1920x1080 PNG weighs between 1 and 4 MB. Since this file **is** versioned,
compressing it is worthwhile. The opaque alpha channel can be discarded:

```sh
python3 -c "
from PIL import Image
im = Image.open('config/Wallpapers/default-wallpaper.jpg')
im.convert('RGB').save('config/Wallpapers/default-wallpaper.jpg',
                       'JPEG', quality=90, subsampling=0, optimize=True)
"
```

`-quality 90` keeps the image visually identical for photographic content.
**Do not quantize to 256 colors**: in skies and auroras it produces banding
and a very visible color outline under the shader. If you need PNG instead of
JPEG, use `optimize=True` and accept the larger file size.
