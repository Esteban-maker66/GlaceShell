# Code & Design Style Guide

## QML Code Conventions
1. **Formatting & Structure**:
   - Order: `id` first, followed by custom properties, anchors, visual properties, and child elements.
   - Use explicit imports with aliases (e.g., `import "../quickshell/components" as GlaceComponent`).
   - Every component that gets used outside its own file must have a matching
     line in `config/quickshell/components/qmldir`.

2. **Naming Conventions**:
   - Component files: `PascalCase.qml` (e.g., `BatteryPill.qml`).
   - Property names: `camelCase` (e.g., `lowThreshold`).
   - Exception: `topVolumeBar.qml` keeps its historical lowercase name because
     it is a public entry point. Prefer `PascalCase.qml` for anything new.

3. **Resolving Resources**:
   - Never hardcode an absolute path. Use `Qt.resolvedUrl("../fonts/...")` so the
     component keeps working from a checkout and from an installed theme.
   - `scripts/maintenance/check-portability.sh` enforces this in CI.

## Glassmorphic Design Token Guidelines
- **Color Palette**:
  - Text / high emphasis: `#FFFFFF`; muted label text: `#efefef`.
  - Glass fill / active fill: white tint from `#33FFFFFF` to `#FFFFFF`.
  - Shadow tints: `#1d1d1d2d`, `#b1000002`, `#6c000000`, `#9f000000`.
  - Warning / low battery state: `#d40000` (exposed as `lowColor` in `BatteryPill`).
  - Shadows and overlays are **not** pure black; always use an alpha tint so the
    blur behind them stays visible.

- **Typography**:
  - The project has two typographic layers. Do not mix them within one surface.

  | Layer | Family | Files | Used by |
  | :--- | :--- | :--- | :--- |
  | **Shell (primary)** | **Noto Sans** | `config/fonts/NotoSans.ttf` (variable, 9 weights), `NotoSans-Italic.ttf` | The desktop shell, and any new component added for it. |
  | Greeter | Estedad, Konkhmer Sleokchher | `config/fonts/Estedad-VF.ttf`, `Estedad-Bold.ttf`, `KonkhmerSleokchher-Regular.ttf` | The SDDM greeter components that exist today. |

  - **Noto Sans is the primary family for the shell.** `NotoSans.ttf` is a
    variable font covering Thin to Black in a single 2 MB file, and it is the
    only Noto Sans file the repository tracks. `NotoSans-Italic.ttf` ships
    alongside it for italic text.
  - Per-weight statics live in `config/fonts/extra/`, which is **gitignored**:
    it holds 72 files (44 MB) that repeat weights the variable font already
    provides. Use the variable font, or drop a static you need into
    `config/fonts/` and commit just that file. The `Condensed`,
    `SemiCondensed` and `ExtraCondensed` widths are only available locally.
  - Selecting a specific weight from a variable font in Qt 6 is unreliable, so
    prefer a static `NotoSans-<Weight>.ttf` when a component needs an exact
    weight. Declare a system fallback alongside it.
  - `config/fonts/Estedad-VF.ttf` is a variable face as well, and **defaults to
    the Thin instance** when loaded. Select an explicit weight or use
    `Estedad-Bold.ttf`; this is why the greeter components load the static bold.
    `KonkhmerSleokchher-Regular.ttf` is a display face for the clock and weather.
  - Load through `FontLoader` or a `fontSource` property that points at a
    `Qt.resolvedUrl(...)` path, with a system fallback declared. Never reference
    a font by absolute path.

- **Animations**:
  - Fluid transitions run between `300ms` and `450ms`; micro-interactions
    (hover, press, icon swaps) are shorter, between `60ms` and `200ms`.
  - Preferred easing: `Easing.OutCubic` for movements, `Easing.OutQuad` for
    short UI feedback, `Easing.OutBack` for dock and entry triggers.
  - Use `Easing.InCubic` / `Easing.InOutQuad` when reversing a movement, so the
    exit reads as the mirror of the entrance.
  - Stagger sibling items (for example, dock actions) instead of animating the
    group as a block.

## Documentation Conventions
- Document the contract, not the implementation: property tables, defaults and
  behavioral notes. See `COMPONENT-SPEC.md`.
- When a component is a placeholder or a stub, say so explicitly with a
  `Status` note rather than leaving it undocumented.
- Keep the documented property defaults in sync with the QML. The tables in
  `COMPONENT-SPEC.md` are written from the source.
