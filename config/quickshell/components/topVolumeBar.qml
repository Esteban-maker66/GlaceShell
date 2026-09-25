import QtQuick

Item {
    id: volumeContainer

    readonly property bool expanded: hoverArea.containsMouse || hoverHeld
    readonly property bool active: isVisible || expanded
    readonly property int pulsePadding: 7
    readonly property int barWidth: expanded ? 500 : 300
    readonly property int barHeight: expanded ? 36 : 10
    readonly property real restingTopMargin: (expanded ? 20 : 18) - pulsePadding
    property real slideOffset: active ? 0 : -(restingTopMargin + pulsePadding + barHeight)
    // State properties
    property real volumeLevel: 0.65
    // Range: 0.0 to 1.0
    property real lastAudibleVolume: 0.65
    readonly property real displayedVolumeLevel: isMuted ? 0 : volumeLevel
    property bool hoverHeld: false
    property bool isMuted: false
    property bool isVisible: false
    property string bridgeUrl: "http://127.0.0.1:18765"
    property bool bridgeAvailable: false
    property bool _stateRequestPending: false

    function requestState() {
        if (_stateRequestPending)
            return;

        _stateRequestPending = true;
        var xhr = new XMLHttpRequest();
        xhr.open("GET", bridgeUrl + "/state", true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;

            volumeContainer._stateRequestPending = false;
            if (xhr.status === 200) {
                volumeContainer.bridgeAvailable = true;
                applySystemState(xhr.responseText);
            } else {
                volumeContainer.bridgeAvailable = false;
            }
        };
        xhr.send();
    }

    function applySystemState(output) {
        try {
            var state = JSON.parse(output);
            volumeContainer.isMuted = state.isMuted;
            volumeContainer.volumeLevel = clampVolume(state.volume / 100);
            if (!state.isMuted && volumeContainer.volumeLevel > 0)
                volumeContainer.lastAudibleVolume = volumeContainer.volumeLevel;
        } catch (error) {
            console.warn("Could not read the system volume:", error);
        }
    }

    function sendCommand(endpoint, payload) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", bridgeUrl + "/" + endpoint, true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;

            if (xhr.status === 200) {
                volumeContainer.bridgeAvailable = true;
                applySystemState(xhr.responseText);
            } else {
                volumeContainer.bridgeAvailable = false;
            }
        };
        xhr.send(JSON.stringify(payload));
    }

    onExpandedChanged: expansionBounce.restart()

    function clampVolume(value) {
        return Math.min(1, Math.max(0, value));
    }

    function volumeFromMouseX(mouseX) {
        return clampVolume((mouseX - bg.x) / bg.width);
    }

    function reveal() {
        volumeContainer.isVisible = true;
        hideTimer.restart();
    }

    function setVolume(value) {
        var nextVolume = clampVolume(value);
        volumeContainer.volumeLevel = nextVolume;
        volumeContainer.isMuted = nextVolume === 0;
        if (!volumeContainer.isMuted)
            volumeContainer.lastAudibleVolume = volumeContainer.volumeLevel;

        sendCommand("set", { "value": nextVolume });
        levelPulse.restart();
        reveal();
    }

    function triggerVolumeChange(delta) {
        var baseVolume = volumeContainer.isMuted && delta > 0 ? volumeContainer.lastAudibleVolume : volumeContainer.volumeLevel;
        setVolume(baseVolume + delta);
    }

    function toggleMute() {
        var nextMuted = !volumeContainer.isMuted;
        volumeContainer.isMuted = nextMuted;

        sendCommand("mute", { "muted": nextMuted });
        reveal();
    }

    Component.onCompleted: requestState()

    // Dimensions and position
    width: barWidth + pulsePadding * 2
    height: barHeight + pulsePadding * 2
    anchors.top: parent.top
    anchors.topMargin: restingTopMargin
    anchors.horizontalCenter: parent.horizontalCenter
    opacity: 1
    clip: true

    // Timer to automatically hide the bar after 2.25 seconds of inactivity
    Timer {
        id: hideTimer

        interval: 2250
        onTriggered: volumeContainer.isVisible = false
    }

    // The IPC service may start after the shell. Keep trying until it is ready.
    Timer {
        id: bridgeRetryTimer

        interval: 5000
        repeat: true
        running: true
        onTriggered: {
            if (!volumeContainer.bridgeAvailable)
                volumeContainer.requestState()
        }
    }

    SequentialAnimation {
        id: levelPulse

        NumberAnimation {
            target: bg
            property: "scale"
            to: 1
            duration: 90
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            target: bg
            property: "scale"
            to: 1.005
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation {
        id: expansionBounce

        NumberAnimation {
            target: bg
            property: "scale"
            to: 1.005
            duration: 300
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: bg
            property: "scale"
            to: 0.995
            duration: 300
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: bg
            property: "scale"
            to: 1
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }

    // Clean visual bar
    Rectangle {
        id: bg

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: volumeContainer.pulsePadding + 28
        anchors.rightMargin: volumeContainer.pulsePadding
        anchors.topMargin: volumeContainer.pulsePadding
        anchors.bottomMargin: volumeContainer.pulsePadding
        radius: height / 2
        color: volumeContainer.expanded ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.2)
        
        Rectangle {
            id: compactFill

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: volumeContainer.expanded ? 2 : 1
            width: (parent.width - (volumeContainer.expanded ? 2 : 1)) * volumeContainer.displayedVolumeLevel
            radius: height / 2
            color: volumeContainer.isMuted ? Qt.rgba(1, 1, 1, 1) : Qt.rgba(0.92, 0.92, 0.92, 1)
            opacity: 1
            
            Behavior on width {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 180
                    easing.type: Easing.OutQuad
                }
            }
        }

        VolumeIcon {
            id: volumeIndicator
            width: 30
            height: 30
            anchors.left: parent.left
            anchors.leftMargin: 9
            anchors.verticalCenter: parent.verticalCenter
            level: volumeContainer.volumeLevel
            muted: volumeContainer.isMuted
            opacity: volumeContainer.expanded ? 1 : 0
            z: 2

            Behavior on opacity {
                NumberAnimation {
                    duration: 240
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    // Mouse interaction area
    Timer {
        id: hoverHideTimer

        interval: 2250
        repeat: false
        onTriggered: {
            volumeContainer.hoverHeld = false;
            volumeContainer.isVisible = false;
        }
    }

    MouseArea {
        // Volume calculation based on horizontal mouse dragging

        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        onEntered: {
            hideTimer.stop();
            hoverHideTimer.stop();
            volumeContainer.hoverHeld = true;
            volumeContainer.isVisible = true;
        }
        onExited: {
            hoverHideTimer.restart();
        }
        onPositionChanged: mouse => {
            if (pressed)
                volumeContainer.setVolume(volumeContainer.volumeFromMouseX(mouse.x));
        }

        onWheel: wheel => {
            var wheelDelta = wheel.angleDelta.y;
            if (wheelDelta === 0)
                wheelDelta = wheel.pixelDelta.y;
            if (wheelDelta === 0)
                return;

            var step = 0.05;
            if (wheel.angleDelta.y !== 0)
                step *= Math.abs(wheelDelta / 340);

            volumeContainer.triggerVolumeChange(wheelDelta > 0 ? step : -step);
            wheel.accepted = true;
        }
        onClicked: mouse => {
            volumeContainer.setVolume(volumeContainer.volumeFromMouseX(mouse.x));
        }
    }

    // System keyboard shortcuts (multimedia keys)
    Shortcut {
        sequences: ["Volume Up", "Ctrl+Up", "Alt+="]
        onActivated: volumeContainer.triggerVolumeChange(0.05)
    }

    // Volume down
    Shortcut {
        sequences: ["Volume Down", "Ctrl+Down", "Alt+-"]
        onActivated: volumeContainer.triggerVolumeChange(-0.05)
    }

    // Mute audio
    Shortcut {
        sequences: ["Volume Mute", "Ctrl+M"]
        onActivated: volumeContainer.toggleMute()
    }

    transform: Translate {
        y: volumeContainer.slideOffset
    }

    // Smooth transition animations for dimensions and position
    Behavior on width {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    Behavior on anchors.topMargin {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    Behavior on slideOffset {
        NumberAnimation {
            duration: 360
            easing.type: Easing.OutCubic
        }
    }
}
