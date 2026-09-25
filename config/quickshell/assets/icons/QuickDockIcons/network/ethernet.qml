import QtQuick
import QtQuick.Shapes

// Ethernet icon (monitor + RJ45 connector) with a connected/disconnected transition.
// connected: true  -> normal icon
// connected: false -> the diagonal bar is drawn and cuts through the monitor corner and cable
Item {
    id: root

    property bool connected: true
    property color color: "#FFFFFF"
    property real size: 40
    property int duration: 200

    implicitWidth: size
    implicitHeight: size
    layer.enabled: true
    layer.samples: 128

    function toggle()  { connected = !connected }
    function connect() { connected = true }
    function disconnect() { connected = false }

    // 40-unit grid
    readonly property real k: size / 40
    readonly property real sw: 3.5 * k

    // Slash progress: 0 = connected, 1 = disconnected
    property real slashP: connected ? 0 : 1
    Behavior on slashP {
        NumberAnimation { duration: root.duration; easing.type: Easing.InOutCubic }
    }

    // The upper-left corner opens as soon as the bar starts;
    // the cable shortens when the bar reaches its height.
    readonly property real cornerCut: Math.max(0, Math.min(1, slashP / 0.2))
    readonly property real cableCut: Math.max(0, Math.min(1, (slashP - 0.7) / 0.25))

    // ── Screen: top and left lines + bottom corner + base ──
    Shape {
        anchors.fill: parent
        antialiasing: true

        // Top line
        ShapePath {
            strokeColor: root.color
            strokeWidth: root.sw
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            startX: 24.85 * root.k
            startY: 1.75 * root.k
            PathLine {
                x: (7.25 + 0.95 * root.cornerCut) * root.k
                y: 1.75 * root.k
            }
        }

        // Left side, bottom corner, and bottom line
        ShapePath {
            strokeColor: root.color
            strokeWidth: root.sw
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            startX: 2.25 * root.k
            startY: (6.75 + 1.45 * root.cornerCut) * root.k
            PathLine { x: 2.25 * root.k; y: 26.25 * root.k }
            PathArc {
                x: 7.25 * root.k
                y: 31.25 * root.k
                radiusX: 5 * root.k
                radiusY: 5 * root.k
                direction: PathArc.Counterclockwise
            }
            PathLine { x: 28.75 * root.k; y: 31.25 * root.k }
        }
    }

    // ── Upper-left corner (disappears as the bar passes) ──
    Shape {
        anchors.fill: parent
        antialiasing: true
        visible: root.cornerCut < 1

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.sw
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: 7.25 * root.k
                centerY: 6.75 * root.k
                radiusX: 5 * root.k
                radiusY: 5 * root.k
                startAngle: 180 + 45 * root.cornerCut
                sweepAngle: 90 * (1 - root.cornerCut)
            }
        }
    }

    // ── Stand: two legs and base ─────────────────────
    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.sw
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: 13.85 * root.k
            startY: 31.25 * root.k
            PathLine { x: 13.85 * root.k; y: 38.25 * root.k }
        }
        ShapePath {
            strokeColor: root.color
            strokeWidth: root.sw
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: 26.6 * root.k
            startY: 31.25 * root.k
            PathLine { x: 26.6 * root.k; y: 38.25 * root.k }
        }
        ShapePath {
            strokeColor: root.color
            strokeWidth: root.sw
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: 10.8 * root.k
            startY: 38.25 * root.k
            PathLine { x: 28.9 * root.k; y: 38.25 * root.k }
        }
    }

    // ── RJ45 connector (filled with two empty windows) ──
    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeWidth: -1
            fillColor: root.color
            fillRule: ShapePath.OddEvenFill

            // Outline
            startX: 31.7 * root.k
            startY: 0
            PathLine { x: 37.2 * root.k; y: 0 }
            PathArc { x: 40 * root.k; y: 2.8 * root.k; radiusX: 2.8 * root.k; radiusY: 2.8 * root.k }
            PathLine { x: 40 * root.k; y: 12.8 * root.k }
            PathLine { x: 36.25 * root.k; y: 16.5 * root.k }
            PathLine { x: 32.6 * root.k; y: 16.5 * root.k }
            PathLine { x: 28.9 * root.k; y: 12.8 * root.k }
            PathLine { x: 28.9 * root.k; y: 2.8 * root.k }
            PathArc { x: 31.7 * root.k; y: 0; radiusX: 2.8 * root.k; radiusY: 2.8 * root.k }

            // Top window
            PathMove { x: 32.5 * root.k; y: 3.6 * root.k }
            PathLine { x: 36.4 * root.k; y: 3.6 * root.k }
            PathLine { x: 36.4 * root.k; y: 5.6 * root.k }
            PathLine { x: 32.5 * root.k; y: 5.6 * root.k }
            PathLine { x: 32.5 * root.k; y: 3.6 * root.k }

            // Bottom window (beveled corners)
            PathMove { x: 32.5 * root.k; y: 9.4 * root.k }
            PathLine { x: 36.4 * root.k; y: 9.4 * root.k }
            PathLine { x: 36.4 * root.k; y: 12.2 * root.k }
            PathLine { x: 35.3 * root.k; y: 13.3 * root.k }
            PathLine { x: 33.6 * root.k; y: 13.3 * root.k }
            PathLine { x: 32.5 * root.k; y: 12.2 * root.k }
            PathLine { x: 32.5 * root.k; y: 9.4 * root.k }
        }
    }

    // ── Cable ─────────────────────────────────────────
    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.sw
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: 34.4 * root.k
            startY: 16.5 * root.k
            PathLine {
                x: 34.4 * root.k
                y: (38.25 - 10.95 * root.cableCut) * root.k
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
            strokeWidth: root.sw
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: 1.67 * root.k
            startY: 1.67 * root.k
            PathLine {
                x: (1.67 + 36.66 * root.slashP) * root.k
                y: (1.67 + 36.66 * root.slashP) * root.k
            }
        }
    }
}
