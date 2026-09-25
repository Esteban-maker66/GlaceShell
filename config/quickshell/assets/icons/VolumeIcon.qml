import QtQuick
import QtQuick.Shapes

// level: "mute" | "low" | "medium" | "high"
Item {
    id: root

    property string level: "high"
    property color color: "#000000"
    property real size: 100
    property bool autoPlay: false

    implicitWidth: size
    implicitHeight: size
    layer.enabled: true
    layer.samples: 128

    // Scale factor: everything is drawn on a 70-unit grid
    readonly property real k: size / 70

    // Intro animation progress
    property real noteScale: 0.3
    property real noteOpacity: 0
    property real wave1P: 0
    property real wave2P: 0
    property real wave3P: 0
    property real slashP: 0

    readonly property bool showWaves: level === "medium" || level === "high"

    function play() {
        if (root.level === "mute") {
            intro.stop();
            noteScale = 1;
            noteOpacity = 1;
            wave1P = 0;
            wave2P = 0;
            wave3P = 0;
            slashP = 0;
            intro.restart();
            return;
        }

        noteScale = 0.3;
        noteOpacity = 0;
        wave1P = 0;
        wave2P = 0;
        wave3P = 0;
        slashP = 0;
        intro.restart()
    }

    Component.onCompleted: if (autoPlay) play()

    // Offset to visually center the note + waves group
    Item {
        x: -5 * root.k
        width: root.size
        height: root.size

        // ── Musical note ──────────────────────────────
        Shape {
            id: note
            anchors.fill: parent
            antialiasing: true
            opacity: root.level === "mute" ? 1 : root.noteOpacity
            transform: Scale {
                origin.x: 24 * root.k
                origin.y: 50 * root.k
                xScale: root.level === "mute" ? 1 : root.noteScale
                yScale: root.level === "mute" ? 1 : root.noteScale
            }

            // Head
            ShapePath {
                strokeWidth: -1
                fillColor: root.color
                PathAngleArc {
                    centerX: 20 * root.k
                    centerY: 44 * root.k
                    radiusX: 8 * root.k
                    radiusY: 7 * root.k
                    startAngle: 0
                    sweepAngle: 360
                }
            }

            // Stem + flag
            ShapePath {
                strokeColor: root.color
                strokeWidth: 5 * root.k
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                startX: 26 * root.k
                startY: 44 * root.k
                PathLine { x: 26 * root.k; y: 16 * root.k }
                PathCubic {
                    control1X: 35 * root.k; control1Y: 17 * root.k
                    control2X: 40 * root.k; control2Y: 21 * root.k
                    x: 39 * root.k; y: 30 * root.k
                }
            }
        }

        // ── Wave 1 (medium / high) ────────────────────
        Shape {
            anchors.fill: parent
            antialiasing: true
            visible: root.showWaves && root.wave1P > 0
            ShapePath {
                strokeColor: root.color
                strokeWidth: 4.5 * root.k
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                PathAngleArc {
                    centerX: 40 * root.k
                    centerY: 32 * root.k
                    radiusX: 9 * root.k
                    radiusY: 9 * root.k
                    startAngle: -40
                    sweepAngle: 80 * root.wave1P
                }
            }
        }

        // ── Wave 2 (faint in medium, solid in high) ───
        Shape {
            anchors.fill: parent
            antialiasing: true
            visible: root.showWaves && root.wave2P > 0
            opacity: root.level === "medium" ? 0.35 : 1
            ShapePath {
                strokeColor: root.color
                strokeWidth: 4.5 * root.k
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                PathAngleArc {
                    centerX: 40 * root.k
                    centerY: 32 * root.k
                    radiusX: 17 * root.k
                    radiusY: 17 * root.k
                    startAngle: -40
                    sweepAngle: 80 * root.wave2P
                }
            }
        }

        // ── Diagonal bar (mute) ───────────────────────
        Shape {
            anchors.fill: parent
            antialiasing: true
            visible: root.level === "mute" && root.slashP > 0
            ShapePath {
                strokeColor: root.color
                strokeWidth: 5 * root.k
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                startX: 12 * root.k
                startY: 10 * root.k
                PathLine {
                    x: (12 + 40 * root.slashP) * root.k
                    y: (10 + 44 * root.slashP) * root.k
                }
            }
        }
    }

    // ── Intro animation (runs only once) ──────────────
    ParallelAnimation {
        id: intro

        NumberAnimation {
            target: root; property: "noteScale"
            from: 0.3; to: 1; duration: 600
            easing.type: Easing.OutBack; easing.overshoot: 2
        }
        NumberAnimation {
            target: root; property: "noteOpacity"
            from: 0; to: 1; duration: 400
        }
        SequentialAnimation {
            NumberAnimation {
                target: root; property: "wave1P"
                from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic
            }
        }
        SequentialAnimation {
            PauseAnimation { duration: 150 }
            NumberAnimation {
                target: root; property: "wave2P"
                from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic
            }
        }
        SequentialAnimation {
            PauseAnimation { duration: 300 }
            NumberAnimation {
                target: root; property: "wave3P"
                from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic
            }
        }
        SequentialAnimation {
            NumberAnimation {
                target: root; property: "slashP"
                from: 0; to: 1; duration: 600; easing.type: Easing.OutCubic
            }
        }
    }
}
