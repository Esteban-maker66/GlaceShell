import QtQuick
import QtQuick.Shapes

// Wi-Fi icon with an off/on transition.
// wifiOn: true  -> normal Wi-Fi (dot + 3 complete arcs)
// wifiOn: false -> Wi-Fi off (diagonal bar, arcs cut by the bar)
// When wifiOn changes, the bar is drawn (or retracted) and the arcs open (or close) as it passes.
Item {
    id: root

    property bool wifiOn: true
    property color color: "#FFFFFF"
    property real size: 40
    property int duration: 200

    implicitWidth: size
    implicitHeight: size
    layer.enabled: true
    layer.samples: 128

    function toggle() { wifiOn = !wifiOn }
    function turnOn()  { wifiOn = true }
    function turnOff() { wifiOn = false }

    // 40-unit grid
    readonly property real k: size / 40
    readonly property real cx: 20 * k
    readonly property real cy: 33.33 * k

    // Slash progress: 0 = on, 1 = off
    property real slashP: wifiOn ? 0 : 1
    Behavior on slashP {
        NumberAnimation { duration: root.duration; easing.type: Easing.InOutCubic }
    }

    // Arcs: radius, start/end angles, gap opened by the bar (gS..gE)
    // and the point along the bar (t) where the gap starts to open.
    readonly property var arcs: [
        { r: 8.5,  a0: -131.7, a1: -48.3, gS: -90,   gE: -90,  t: 0,    cut: false },
        { r: 16.9, a0: -133.2, a1: -46.8, gS: -100.5, gE: -62.2, t: 0.37, cut: true  },
        { r: 25.3, a0: -133.9, a1: -46.1, gS: -113.0, gE: -94.9, t: 0.20, cut: true  }
    ]

    // ── Dot ───────────────────────────────────────────
    Rectangle {
        width: 4 * root.k
        height: 4 * root.k
        radius: 2 * root.k
        x: root.cx - 2 * root.k
        y: root.cy - 2 * root.k
        color: root.color
    }

    // ── Arcs ──────────────────────────────────────────
    Repeater {
        model: root.arcs

        delegate: Item {
            id: arc

            required property var modelData

            // How far the gap has opened (0..1)
            readonly property real g: modelData.cut
                ? Math.max(0, Math.min(1, (root.slashP - modelData.t) / 0.18))
                : 0
            readonly property real m: (modelData.gS + modelData.gE) / 2
            readonly property real lEnd: m + (modelData.gS - m) * g
            readonly property real rStart: m + (modelData.gE - m) * g

            anchors.fill: parent

            // Full arc (while there is no gap)
            Shape {
                anchors.fill: parent
                antialiasing: true
                visible: arc.g <= 0
                ShapePath {
                    strokeColor: root.color
                    strokeWidth: 4 * root.k
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    PathAngleArc {
                        centerX: root.cx
                        centerY: root.cy
                        radiusX: arc.modelData.r * root.k
                        radiusY: arc.modelData.r * root.k
                        startAngle: arc.modelData.a0
                        sweepAngle: arc.modelData.a1 - arc.modelData.a0
                    }
                }
            }

            // Arc split into two sections (with a gap)
            Shape {
                anchors.fill: parent
                antialiasing: true
                visible: arc.g > 0

                // Left section
                ShapePath {
                    strokeColor: root.color
                    strokeWidth: 4 * root.k
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    PathAngleArc {
                        centerX: root.cx
                        centerY: root.cy
                        radiusX: arc.modelData.r * root.k
                        radiusY: arc.modelData.r * root.k
                        startAngle: arc.modelData.a0
                        sweepAngle: arc.lEnd - arc.modelData.a0
                    }
                }

                // Right section
                ShapePath {
                    strokeColor: root.color
                    strokeWidth: 4 * root.k
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    PathAngleArc {
                        centerX: root.cx
                        centerY: root.cy
                        radiusX: arc.modelData.r * root.k
                        radiusY: arc.modelData.r * root.k
                        startAngle: arc.rStart
                        sweepAngle: arc.modelData.a1 - arc.rStart
                    }
                }
            }
        }
    }

    // ── Diagonal bar ────────────────────────────────
    Shape {
        anchors.fill: parent
        antialiasing: true
        visible: root.slashP > 0

        ShapePath {
            strokeColor: root.color
            strokeWidth: 4 * root.k
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: 1.6665 * root.k
            startY: 1.6666 * root.k
            PathLine {
                x: (1.6665 + 36.6667 * root.slashP) * root.k
                y: (1.6666 + 36.6667 * root.slashP) * root.k
            }
        }
    }
}
