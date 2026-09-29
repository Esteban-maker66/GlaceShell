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
| `bridgeUrl` | `string` | `http://127.0.0.1:18765` | Base URL of the network IPC bridge. |
| `wifiAvailable` | `bool` | `false` | A WiFi device is reported by the bridge. |
| `wifiConnected` | `bool` | `false` | The WiFi device has an active connection. |
| `wifiEnabled` | `bool` | `false` | WiFi radio state. |
| `wifiSignal` | `int` | `0` | Active WiFi signal strength, `0`-`100`. |
| `ethernetAvailable` | `bool` | `false` | An Ethernet device is reported by the bridge. |
| `ethernetConnected` | `bool` | `false` | The Ethernet device has an active connection. |
| `bluetoothFeatureEnabled` | `bool` | `false` | Master switch for the Bluetooth control; disabled during the first integration pass. |
| `bluetoothAvailable` | `bool` | `false` | A Bluetooth device is reported by the bridge. |
| `bluetoothEnabled` | `bool` (readonly) | derived | Mirrors `bluetoothFeatureEnabled` for the icon loader. |
| `wifiBars` | `int` (readonly) | derived | Signal strength as 0-3 bars: `>= 75` is 3, `>= 50` is 2, `>= 25` is 1, else 0. |
| `wifiIconSource` | `string` (readonly) | derived | Resolves `wifi-<bars>.svg` when enabled and connected, else `wifi-0.svg`. |

### Signals
| Signal | Emitted when |
| :--- | :--- |
| `suspendRequested()` | The suspend action is triggered. |
| `restartRequested()` | The restart action is triggered. |
| `powerRequested()` | The power-off action is triggered. |

`config/sddm/main.qml` handles all three through `performPowerAction()`,
which checks the `sddm` global before calling into the greeter.

### Features
- **180° Rotation Trigger**: Rotating animation on the launcher icon with `Easing.OutBack`.
- **Power Actions**: Suspend, restart, and power off are emitted as signals and handled by the SDDM context in `config/sddm/main.qml`.
- **WiFi Control**: Toggles the WiFi radio through the bridge and selects `wifi-0.svg` through `wifi-3.svg` from the reported signal strength (`0-24`, `25-49`, `50-74`, `75-100`).
- **Ethernet Control**: Shows the Ethernet icon only when an Ethernet device is present; the connected/disconnected state is reflected by the icon.
- **Staggered Entry**: Each action fades in and slides from a 15px offset with `Easing.OutCubic`, then settles with a press-scale interaction.

### Behavioral Specs
- Network state is polled every five seconds from `GET /network`; unavailable devices remain hidden.
- Bluetooth is intentionally hidden and disabled until its control path is implemented and tested.
- Power signals are ignored outside an SDDM context, so the reusable component remains safe in previews.

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
| `slideOffsetY` | `real` | `0` | Vertical travel added on top of the layout position. |
| `timeString` | `string` | `""` | 12-hour time, `hh:mm`. Written by the internal timer. |
| `dateString` | `string` | `""` | Localized `weekday, day month`. Written by the internal timer. |

### Behavioral Specs
- **`slideOffsetY` exists so `y` can be animated without breaking its binding.**
  `y` is bound to `verticalPosition`; animating `y` directly would destroy that
  binding and leave the clock stranded off-screen. Adding the offset as a
  separate property keeps the layout binding intact, so the clock returns to
  its resting place on its own when the offset returns to 0.
- Used by the login transition to fly the clock up and out of the screen.
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
The glass panel revealed by the login transition, drawn above the blur layer so
it stays sharp while the backdrop is diffused.

### Properties
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `ready` | `bool` (readonly) | derived | `opacity > 0.01`. Lets callers tell a settled prompt from one still fading in. |

### Behavioral Specs
- The panel itself never fades or moves; `config/sddm/main.qml` drives `opacity`.
  Keeping the animation in the caller means the whole view shares one timeline.
- Uses a `#1b1b1b3d` glass fill with a `#ffffff33` border, consistent with the
  tokens in `STYLE.md`, plus a `MultiEffect` drop shadow so the panel separates
  from the blurred wallpaper.

> **Status**: visual shell only. SDDM themes authenticate through its login
> capability (`UserModel`); that integration is not implemented, so the panel
> has no credential fields and nothing here submits anything.

---

## 11. General Blur (`GeneralBlur.qml`)
Native Gaussian blur applied to another item's content. Registered in `qmldir`
from the start, but only now has an implementation.

### Properties
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `target` | `Item` | `null` | Item whose content gets blurred. Usually the layer holding the backdrop. |
| `radius` | `real` | `48` | Maximum blur radius in px. `amount` scales between 0 and this. |
| `amount` | `real` | `0` | `0` = no blur, `1` = full `radius`. Animate this. |

### Behavioral Specs
- **The target keeps its own visibility.** `MultiEffect` renders the captured,
  blurred result on top of the target, and because that output is opaque it
  covers the sharp original. This avoids hiding the source, whose capture
  behaviour when `visible: false` is not something to rely on — and it keeps
  the target's input working, which matters because `uiLayer` carries the
  click-to-collapse `MouseArea`.
- **Zero cost when inactive.** `visible: amount > 0.001` skips the effect
  entirely instead of drawing a transparent pass over the whole screen.
- Rendered by Qt's native effect backend, which compiles to a GLSL fragment
  shader and runs on the GPU. A hand-written `ShaderEffect` would add code,
  lose the hardware path, and gain nothing visually.

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
| `GET` | `/network` | WiFi/Ethernet device, connection, radio, and signal state. | `QuickDock` |
| `POST` | `/set` | Sets the default sink volume. | `topVolumeBar` |
| `POST` | `/mute` | Toggles mute. | `topVolumeBar` |
| `POST` | `/keyboard` | Changes the keyboard layout. | `KeyLangBtn` |
| `POST` | `/network` | Toggles a network device (WiFi, Ethernet, Bluetooth). | `QuickDock` |
| `POST` | `/network` | Applies `toggleWifi` or `toggleEthernet`. | `QuickDock` |
