# Screenshots

Project images referenced from `README.md` and from the `Screenshot=` field of
`config/sddm/metadata.desktop`.

## Conventions

- **Format:** PNG for interface screenshots. JPG only when the image is a
  photograph without text (for example, a wallpaper with no interface on top).
- **Aspect ratio:** 16:9. The greeter screenshot uses a minimum of `1600x900`.
- **Name:** lowercase with hyphens, descriptive of the content.
  `sddm-greeter.png`, not `Screenshot.png`.
- **No personal data:** no notifications, email, visible IP address, or
  usernames. In dotfiles, the screenshot is the first surface where
  information is exposed.

## Expected files

| File | Status | Used in |
| :--- | :--- | :--- |
| `sddm-greeter.png` | Placeholder | `README.md` (greeter) and the theme thumbnail in the SDDM browser. |
| `shell-desktop.png` | Placeholder | `README.md` (desktop shell), reserved for when the shell enters the demo. |

## Optimize before uploading

```sh
pngquant --quality=80-95 docs/screenshots/sddm-greeter.png
```

`optipng -o2` also works and does not lose color. Always review the result in
an image viewer before overwriting: an interface screenshot with text
compressed too aggressively will look blurry.
