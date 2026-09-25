import QtQuick
import QtQuick.Shapes

// Bluetooth icon with an on/off transition.
// btOn: true  -> normal symbol
// btOn: false -> the diagonal bar is drawn over the symbol's diagonal and cuts
//               through its upper half (the vertical stroke and upper-right arm)
Item {
    id: root

    property bool btOn: true
    property color color: "#FFFFFF"
    property real size: 40
    property int duration: 200

    implicitWidth: size
    implicitHeight: size
    layer.enabled: true
    layer.samples: 128

    function toggle()  { btOn = !btOn }
    function turnOn()  { btOn = true }
    function turnOff() { btOn = false }

    // 40-unit grid
    readonly property real k: size / 40
    readonly property real sw: 4 * k

    // Slash progress: 0 = on, 1 = off
    property real slashP: btOn ? 0 : 1
    Behavior on slashP {
        NumberAnimation { duration: root.duration; easing.type: Easing.InOutCubic }
    }

    // The gap opens when the bar crosses the center of the symbol (slashP ≈ 0.5)
    readonly property real cut: Math.max(0, Math.min(1, (slashP - 0.42) / 0.22))

    Shape {
        anchors.fill: parent
        antialiasing: true

        // Symbol diagonal (stays below the bar when off)
        ShapePath {
            strokeColor: root.color
            strokeWidth: root.sw
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            startX: 10.8335 * root.k
            startY: 10.8333 * root.k
            PathLine { x: 29.1668 * root.k; y: 29.1666 * root.k }
        }

        // Lower half: diagonal to the lower tip and vertical stroke to the center
        ShapePath {
            strokeColor: root.color
            strokeWidth: root.sw
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            startX: 29.1668 * root.k
            startY: 29.1666 * root.k
            PathLine { x: 20 * root.k; y: 38.3333 * root.k }
            PathLine { x: 20 * root.k; y: 20 * root.k }
        }

        // Upper half: vertical stroke, upper tip, and right arm (shortens when off)
        ShapePath {
            strokeColor: root.color
            strokeWidth: root.sw
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            startX: 20 * root.k
            startY: (20 - 9.5 * root.cut) * root.k
            PathLine { x: 20 * root.k; y: 1.6666 * root.k }
            PathLine { x: 29.1668 * root.k; y: 10.8333 * root.k }
            PathLine {
                x: (20 + 4.74 * root.cut) * root.k
                y: (20 - 4.74 * root.cut) * root.k
            }
        }

        // Lower-left arm
        ShapePath {
            strokeColor: root.color
            strokeWidth: root.sw
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            startX: 20 * root.k
            startY: 20 * root.k
            PathLine { x: 10.8335 * root.k; y: 29.1666 * root.k }
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
            startX: 2 * root.k
            startY: 2 * root.k
            PathLine {
                x: (2 + 36 * root.slashP) * root.k
                y: (2 + 36 * root.slashP) * root.k
            }
        }
    }
}
