# Component Specifications

Contract for each QML component registered in `config/quickshell/components/qmldir`.
Components access the system exclusively through `glaceBridge` (HTTP on
`127.0.0.1:18765`); none of them reads `/sys` directly.

Covered components: `BackgroundShader`, `BatteryPill`, `ClockWidget`,
`DisplayWeather`, `GeneralBlur`, `KeyLangBtn`, `LoginPrompt`, `QuickDock`,
`Slider`, `TopVolumeBar`, `VolumeIcon`, and `WeatherIcon`.

---

## 1. BatteryPill (`BatteryPill.qml`)
A dynamic pill indicator with fluid height animations and status icons.

### Properties
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `level` | `int` | `100` | Current battery percentage (0-100). |
| `charging` | `bool` | `false` | Shows bolt icon and slides percentage text left. |
| `powerSaving` | `bool` | `false` | Shows power-saving leaf icon. |
| `lowThreshold` | `int` | `20` | Threshold to trigger low-battery color fade (`lowColor`). |
| `pillWidth` / `pillHeight` | `real` | `26` / `40` | Geometry of the fill container. |
| `fillInset` | `real` | `1` | Keeps the level inside the pill when the fill is very short. |
| `pillColor` | `color` | `#33FFFFFF` | Glass fill of the container. |
| `iconColor` | `color` | `#ff000000` | Icon tint. |
| `textColor` | `color` | `#FFFFFF` | Percentage label color. |
| `lowColor` | `color` | `#d40000` | Target color of the fade when `level <= lowThreshold`. |
| `fontSource` | `url` | `../../fonts/Estedad-VF.ttf` | Resolved relative to this file. |
| `fontSize` | `int` | `13` | Percentage label size. |
| `enterDuration` | `int` | `380` | Slide-in duration in ms. |
| `slideDuration` | `int` | `420` | Label slide duration in ms. |
| `colorFadeDuration` | `int` | `350` | Low-battery color fade duration in ms. |
| `useSysfs` | `bool` | `true` | Set `false` in previews to drive `level`/`charging` manually. |
| `pollInterval` | `int` | `30000` | Polling period for `/battery` in ms. |
| `bridgeUrl` | `string` | `http://127.0.0.1:18765` | Base URL of `glaceBridge`. |
| `isLow` | `bool` (readonly) | derived | `level <= lowThreshold`. Drives the fade to `lowColor` on both the icon and the label. |

### Behavioral Specs
- **Text Clipping Avoidance**: The percentage label (`Text`) is rendered outside the main `Rectangle` container to avoid truncation when `clip: true` is active.
- **Hardware Fallback**: Automatically hides (`visible: false`) when `/battery` reports that no battery interface is available. The bridge reads the kernel sysfs files, so QML does not need local-file XHR access.

---

## 2. Quick Dock (`QuickDock.qml`)
A floating vertical action dock triggered by an animated logo.

### Properties
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `expanded` | `bool` | `false` | Expands the dock into its action list. |
| `animating` | `bool` | `false` | True while a transition is running. |
| `lastClickTime` | `real` | `0` | Timestamp of the last trigger, used to debounce. |
| `iconBase` | `string` (readonly) | `../assets/icons/QuickDockIcons` | Directory the action glyphs resolve against. |

### Features
- **180° Rotation Trigger**: Rotating animation on the launcher icon with `Easing.OutBack`.
- **Action Bindings**: Power Off, Reboot, Suspend, and Network/Bluetooth toggles.
- **Staggered Entry**: Each action fades in and slides from a 15px offset with `Easing.OutCubic`, then settles with a press-scale interaction.

> **Status**: the network and Bluetooth toggles are not connected to the system's actual network.

---

## 3. Top Volume Bar (`topVolumeBar.qml`)
Sliding bar that controls the audio sink through the bridge.

### Properties
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `volumeLevel` | `real` | `0.65` | Current volume, `0.0` to `1.0`. |
| `lastAudibleVolume` | `real` | `0.65` | Restored when unmuting. |
| `isMuted` | `bool` | `false` | Mute state reported by the sink. |
| `isVisible` | `bool` | `false` | Controls the slide-in/out offset. |
| `hoverHeld` | `bool` | `false` | Keeps the bar open while hovered. |
| `bridgeUrl` | `string` | `http://127.0.0.1:18765` | Base URL of `glaceBridge`. |
| `bridgeAvailable` | `bool` | `false` | Set from a `GET /state` probe. |
| `expanded` | `bool` (readonly) | derived | `hoverArea.containsMouse \|\| hoverHeld`. |
| `active` | `bool` (readonly) | derived | `isVisible \|\| expanded`. Drives `slideOffset`. |
| `displayedVolumeLevel` | `real` (readonly) | derived | `isMuted ? 0 : volumeLevel`. Drives the fill width. |
| `barWidth` | `int` (readonly) | `500` / `300` | Width when expanded / collapsed. |
| `barHeight` | `int` (readonly) | `36` / `10` | Height when expanded / collapsed. |
| `pulsePadding` | `int` (readonly) | `7` | Breathing room around the bar. |
| `restingTopMargin` | `real` (readonly) | derived | Top margin when expanded / collapsed, minus `pulsePadding`. |
| `slideOffset` | `real` | derived | `0` when active, otherwise the hidden offset above the screen. |

### Methods
`requestState()`, `applySystemState(output)`, `sendCommand(endpoint, payload)`,
`clampVolume(value)`, `volumeFromMouseX(mouseX)`, `reveal()`,
`setVolume(value)`, `triggerVolumeChange(delta)`, `toggleMute()`.

### Behavioral Specs
- **Reconnection**: Retries the bridge every five seconds, so a late-starting
  `glace-ipc.service` is picked up without a restart.
- **Unavailable in the greeter**: the service is a *user* service and is not
  running on the SDDM screen before login. The bar stays hidden there.

---

## 4. Clock Widget (`ClockWidget.qml`)
Time and date with a typographic hierarchy.

### Properties
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `horizontalPosition` | `real` | `0.5` | Normalized X position on the parent. |
| `verticalPosition` | `real` | `0.5` | Normalized Y position on the parent. |
| `dateHorizontalOffset` | `real` | `0` | Extra X offset applied to the date line. |
| `dateVerticalOffset` | `real` | `0` | Extra Y offset applied to the date line. |
| `timeString` | `string` | `""` | 12-hour time, `hh:mm`. Written by the internal timer. |
| `dateString` | `string` | `""` | Localized `weekday, day month`. Written by the internal timer. |

### Behavioral Specs
- Updates every second through an internal `Timer` and formats the time and date with the component's built-in English day and month names.
- Reads the system date through `new Date()`, so no bridge round-trip is needed.

---

## 5. Display Weather (`DisplayWeather.qml`)
Current conditions for the user's approximate location.

### Properties
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `cityName` | `string` | `""` | Resolved city, shown next to the temperature. |
| `tempText` | `string` | `""` | Formatted temperature. |
| `weatherIcon` | `string` | `""` | Condition key passed to `WeatherIcon`. |
| `weatherReady` | `bool` | derived | `true` when both `tempText` and `weatherIcon` are set. |

### Behavioral Specs
- **Two-step lookup**: `http://ip-api.com/json` resolves city and coordinates,
  then `https://api.open-meteo.com/v1/forecast` returns the forecast.
- Runs once on `Component.onCompleted`; a failure leaves `weatherReady` `false`
  and hides the widget instead of showing an error.

---

## 6. Weather Icon (`WeatherIcon.qml`)
Picks the SVG that matches a condition key.

### Properties
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `condition` | `string` | `"sun"` | Condition key. |

### Assets
`assets/icons/WeatherIcons/` ships `weather-sun`, `weather-partly-cloudy`,
`weather-cloud`, `weather-rain`, `weather-storm`, `weather-snow` and
`weather-fog`.

---

## 7. Key Language Button (`KeyLangBtn.qml`)
Toggles between the Spanish and English keyboard layouts.

### Properties
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `language` | `string` | `"es"` | Current layout; `"es"` renders `ESP`, anything else `ENG`. |
| `label` | `string` | derived | Binding on `language`. |
| `textPixelSize` | `int` | `20` | Label size. |
| `textColor` | `color` | `#efefef` | Label color. |
| `busy` | `bool` | `false` | Disables input while a layout change is in flight. |

### Behavioral Specs
- Bound to `Ctrl+Space` and to a click on the component.
- Sends `POST /keyboard` to the bridge, which delegates to `qdbus6`, `hyprctl`
  or `setxkbmap` depending on the running session.

---

## 8. Volume Icon (`VolumeIcon.qml`)
Glyph that reflects the current volume and mute state.

### Properties
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `level` | `real` | `0.65` | Volume `0.0`-`1.0`, selects the glyph bucket. |
| `muted` | `bool` | `false` | Forces the muted glyph. |
| `pulsePadding` | `int` | `0` | Extra padding used by the pulse animation. |
| `iconName` | `string` (readonly) | derived | `muted` when muted, otherwise `low` at `<= 0.4`, `medium` at `<= 0.7`, else `high`. |

### Assets
Loads the animated glyph from `assets/icons/VolumeIcon.qml` and maps `iconName`
to the static frames in `assets/icons/VolumeAltIcons/` (`high`, `medium`, `low`,
`muted`).

---

## 9. Background Shader (`BackgroundShader.qml`)
Full-screen shader that renders the wallpaper.

### Properties
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `wallpaperSource` | `url` | `../../Wallpapers/default-wallpaper.jpg` | Wallpaper to sample, resolved relative to this file. |

### Behavioral Specs
- Loads the fragment stage from `config/shaders/Effect.frag`.
- `default-wallpaper.jpg` is the only wallpaper tracked by the repository. The
  rest of `config/Wallpapers/` is gitignored, so a fresh clone has exactly this
  one file. See `config/Wallpapers/README.md`.
- **Fallback backdrop**: a dark gradient is drawn behind the image, so pointing
  `wallpaperSource` at a missing file degrades to a composed background instead
  of a black screen.

---

## 10. Login Prompt (`LoginPrompt.qml`)

> **Status**: skeleton. The component exposes an empty `Item` and does not yet
> implement credential entry. Transitions between the main view and the prompt
> are already wired in `config/sddm/main.qml`.

---

## 11. General Blur (`GeneralBlur.qml`)

> **Status**: empty file. Reserved for the background blur effect.

---

## 12. Slider (`Slider.qml`)

> **Status**: empty file. Reserved for reusable slider controls.

---

## Bridge Endpoints

`config/quickshell/modules/glaceBridge.py` serves on `127.0.0.1:18765`.

| Method | Path | Purpose | Used by |
| :--- | :--- | :--- | :--- |
| `GET` | `/state` | Volume, mute state, and bridge availability. | `topVolumeBar` |
| `GET` | `/battery` | Charge level and charging state from `/sys/class/power_supply`. | `BatteryPill` |
| `POST` | `/set` | Sets the default sink volume. | `topVolumeBar` |
| `POST` | `/mute` | Toggles mute. | `topVolumeBar` |
| `POST` | `/keyboard` | Changes the keyboard layout. | `KeyLangBtn` |
