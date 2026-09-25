import QtQuick
import QtQuick.Shapes

// Battery pill for laptops.
//
// Automatically reads the battery from /sys/class/power_supply/BAT*.
// Automatically hides itself on desktops without a battery.
//
// States:
//  - charging = true   -> lightning bolt (fade + scale) + percentage slides to the left
//  - level <= lowThreshold -> percentage changes to red
//
// For manual testing, set useSysfs: false and control level/charging directly.
Item {
    id: root

    // ── Configuration ─────────────────────────────────
    property bool charging: false
    property bool powerSaving: false
    property int level: 100
    property int lowThreshold: 20

    property real pillWidth: 26
    property real pillHeight: 40
    // Keep the level inside the pill when the fill becomes very short.
    property real fillInset: 1

    property color pillColor: "#33FFFFFF"
    property color iconColor: "#ff000000"
    property color textColor: "#FFFFFF"
    property color lowColor: "#d40000"

    property url fontSource: Qt.resolvedUrl("../../fonts/Estedad-VF.ttf")
    property int fontSize: 13

    property int enterDuration: 380
    property int slideDuration: 420
    property int colorFadeDuration: 350

    // ── Battery state (read by the local bridge) ───────
    // QML must not read /sys directly: XMLHttpRequest blocks local file URLs
    // unless QML_XHR_ALLOW_FILE_READ is enabled. The bridge performs the
    // sysfs read and exposes the result over localhost instead.
    property bool useSysfs: true
    property int pollInterval: 30000
    property string bridgeUrl: "http://127.0.0.1:18765"
    property bool _hasBattery: false
    property bool _bridgeRequestPending: false
    property bool _bridgeErrorReported: false

    implicitWidth: pillWidth + 60
    implicitHeight: pillHeight

    readonly property bool isLow: level <= lowThreshold

    FontLoader {
        id: pctFont
        source: root.fontSource
    }

    // ── Initial battery detection ───────────────────────
    Component.onCompleted: {
        if (useSysfs)
            _requestBattery()
    }

    function _requestBattery() {
        if (_bridgeRequestPending)
            return

        _bridgeRequestPending = true
        var xhr = new XMLHttpRequest()
        xhr.open("GET", bridgeUrl + "/battery", true)
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return

            root._bridgeRequestPending = false
            if (xhr.status !== 200) {
                if (!root._bridgeErrorReported) {
                    console.warn("Could not read battery state:", xhr.responseText || xhr.status)
                    root._bridgeErrorReported = true
                }
                return
            }

            root._bridgeErrorReported = false
            root._applyBatteryState(xhr.responseText)
        }
        xhr.send()
    }

    function _applyBatteryState(output) {
        try {
            var state = JSON.parse(output)
            root._hasBattery = state.available === true
            if (!root._hasBattery)
                return

            var nextLevel = parseInt(state.level)
            if (!isNaN(nextLevel))
                root.level = Math.max(0, Math.min(100, nextLevel))

            root.charging = state.charging === true
            root.powerSaving = state.powerSaving === true
        } catch (error) {
            console.warn("Could not parse the battery state:", error)
        }
    }

    // Poll while a battery is available.
    Timer {
        id: batteryTimer
        interval: root.pollInterval
        running: root.useSysfs && root._hasBattery
        repeat: true
        onTriggered: root._requestBattery()
    }

    // Retry while the bridge or battery is unavailable.
    Timer {
        id: bridgeRetryTimer
        interval: 5000
        running: root.useSysfs && !root._hasBattery
        repeat: true
        onTriggered: root._requestBattery()
    }

    // Hide when no battery is present (desktop)
    visible: useSysfs ? _hasBattery : true

    // ── Pill ──────────────────────────────────────────
    Rectangle {
        id: pill
        x: root.width - root.pillWidth
        y: (root.height - root.pillHeight) / 2
        width: root.pillWidth
        height: root.pillHeight
        radius: 10
        clip: true
        color: root.pillColor
        z: 1

        Rectangle {
            id: fillLevel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: root.fillInset
            anchors.rightMargin: root.fillInset
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.fillInset
            height: Math.max(0, (parent.height - root.fillInset * 2) *
                (Math.max(0, Math.min(100, root.level)) / 100.0))
            // A fixed radius becomes invalid when the fill is shorter than
            // twice its radius. Clamp it to the current fill dimensions.
            radius: Math.max(0, Math.min(
                parent.radius - root.fillInset,
                width / 2,
                height / 2
            ))
            visible: height > 0
            color: root.isLow ? root.lowColor : root.textColor
            opacity: 0.85

            Behavior on height {
                NumberAnimation { duration: root.slideDuration; easing.type: Easing.OutCubic }
            }
            Behavior on color {
                ColorAnimation { duration: root.colorFadeDuration }
            }
        }

        // ── Lightning bolt (charging) ──────────────────
        Shape {
            id: bolt
            anchors.centerIn: parent
            width: 11
            height: 18
            opacity: 0
            scale: 0.4
            transformOrigin: Item.Center
            visible: opacity > 0

            ShapePath {
                strokeWidth: -1
                fillColor: root.iconColor
                startX: 7.2; startY: 0
                PathLine { x: 0; y: 10.2 }
                PathLine { x: 4.1; y: 10.2 }
                PathLine { x: 3.1; y: 18 }
                PathLine { x: 11; y: 7 }
                PathLine { x: 6.6; y: 7 }
                PathLine { x: 7.2; y: 0 }
            }

            states: State {
                name: "in"; when: root.charging
                PropertyChanges { target: bolt; opacity: 1; scale: 1 }
            }
            transitions: Transition {
                NumberAnimation {
                    properties: "opacity,scale"
                    duration: root.enterDuration
                    easing.type: root.charging ? Easing.OutBack : Easing.InCubic
                    easing.overshoot: 1.6
                }
            }
        }
    }

    // ── Percentage ─────────────────────────────────────
    Text {
        id: pctText
        text: root.level + "%"
        font.family: pctFont.name.length ? pctFont.name : undefined
        font.pixelSize: root.fontSize
        color: root.isLow ? root.lowColor : root.textColor
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        height: root.pillHeight

        x: root.charging ? (pill.x - width - 8) : (pill.x - width - 4)
        y: (root.height - height) / 2
        z: 2

        Behavior on x {
            NumberAnimation { duration: root.slideDuration; easing.type: Easing.OutCubic }
        }
        Behavior on color {
            ColorAnimation { duration: root.colorFadeDuration }
        }
    }
}
