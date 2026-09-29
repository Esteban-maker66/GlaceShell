import "../quickshell/components" as GlaceComponent
import QtQuick
import QtQuick.Window

Rectangle {
    id: root

    property string transitionState: "main"

    // The "Press Space to Unlock" hint is onboarding: it has done its job the
    // first time the login view opens, and does not come back afterwards.
    property bool hintDismissed: false

    function showLoginPrompt() {
        transitionState = "login";
        fadeToMain.stop();
        slideOut.stop();
        blurIn.stop();
        root.hintDismissed = true;

        clockWidget.visible = true;
        //displayWeather.visible = true;
        spaceHint.visible = true;
        clockWidget.slideOffsetY = 0;
        loginPrompt.visible = true;
        loginPrompt.opacity = 0;
        backdropBlur.amount = 0;

        blurIn.restart();
        slideOut.restart();
    }

    function showMain() {
        transitionState = "main";
        slideOut.stop();
        blurIn.stop();
        fadeToMain.stop();

        loginPrompt.visible = true;
        clockWidget.visible = true;
        //displayWeather.visible = true;
        spaceHint.visible = true;

        fadeToMain.restart();
    }

    function performPowerAction(action) {
        if (typeof sddm === "undefined") {
            console.warn("Power actions require the SDDM greeter context.");
            return;
        }

        if (action === "suspend" && sddm.canSuspend) {
            sddm.suspend();
        } else if (action === "restart" && sddm.canReboot) {
            sddm.reboot();
        } else if (action === "power" && sddm.canPowerOff) {
            sddm.powerOff();
        } else {
            console.warn("The requested power action is not available:", action);
        }
    }

    width: Screen.width
    height: Screen.height
    color: "#0000002a"

    Item {
        id: uiLayer

        anchors.fill: parent

        // Inside uiLayer so the login blur covers the wallpaper together with
        // the widgets. Declared first so the catch-all MouseArea sits above it.
        GlaceComponent.BackgroundShader {
            id: shaderBgRoot

            anchors.fill: parent
            transformOrigin: Item.Center
        }

        // Click anywhere to collapse QuickDock
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: quickDock.collapse()
            
        }

        GlaceComponent.TopVolumeBar {
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }

        GlaceComponent.ClockWidget {
            id: clockWidget
            horizontalPosition: 0.5
            verticalPosition: 0.2
            dateHorizontalOffset: 0
            dateVerticalOffset: -100
        }

        Item {
            id: spaceHint
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 92
            width: 300
            height: 20
            opacity: 1
            visible: true

            FontLoader {
                id: spaceHintFont
                source: Qt.resolvedUrl("../fonts/Estedad-VF.ttf")
            }

            Image {
                id: spaceChevron
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: 31
                height: 31
                source: Qt.resolvedUrl("../quickshell/assets/icons/extraIcons/chevron.svg")
                sourceSize.width: 31
                sourceSize.height: 31
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true

                SequentialAnimation {
                    id: chevronPulse
                    loops: Animation.Infinite
                    running: true
                    PauseAnimation { duration: 5005 }
                    PropertyAnimation { target: spaceChevron; property: "scale"; to: 1.3; duration: 1200; easing.type: Easing.OutQuad }
                    PropertyAnimation { target: spaceChevron; property: "scale"; to: 0.9; duration: 400; easing.type: Easing.InOutQuad }
                    PropertyAnimation { target: spaceChevron; property: "scale"; to: 1.0; duration: 400; easing.type: Easing.OutCubic }
                }
            }

            Text {
                id: spaceHintLabel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: spaceChevron.bottom
                anchors.topMargin: 2
                text: "Press Space to Unlock"
                color: "#F3F3F3"
                opacity: 0.6
                font.family: spaceHintFont.name
                font.pixelSize: 15
                font.weight: Font.Light
                horizontalAlignment: Text.AlignHCenter
                renderType: Text.NativeRendering
            }
        }

        GlaceComponent.QuickDock {
            id: quickDock
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 45
            anchors.bottomMargin: 40
            bluetoothFeatureEnabled: false

            onSuspendRequested: root.performPowerAction("suspend")
            onRestartRequested: root.performPowerAction("restart")
            onPowerRequested: root.performPowerAction("power")

            z: 12
        }

        GlaceComponent.BatteryPill {
            id: batteryPill
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 46
            anchors.topMargin: 32
            useSysfs: true
        }

        /*GlaceComponent.DisplayWeather {
            id: displayWeather
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 32
            anchors.leftMargin: 46

        }*/

        GlaceComponent.KeyLangBtn {
            id: keyLangButton
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 32
            anchors.bottomMargin: 32

            z: 12
        }
    }

    // Gaussian blur over the whole backdrop: wallpaper plus greeter widgets.
    // Drawn above uiLayer and opaque, so it covers the sharp version without
    // uiLayer ever being hidden or its input being taken away.
    GlaceComponent.GeneralBlur {
        id: backdropBlur

        anchors.fill: parent
        target: uiLayer
        radius: 48
        amount: 0
    }

    // Above the blur, so the prompt stays sharp while everything behind it is
    // diffused.
    GlaceComponent.LoginPrompt {
        id: loginPrompt
        anchors.centerIn: parent
        visible: false
    }

    Rectangle {
        id: welcomeOverlay
        anchors.fill: parent
        color: "#000000"
        opacity: 1
        z: 100

        SequentialAnimation {
            id: welcomeFade
            running: true

            PauseAnimation {
                duration: 165
            }

            NumberAnimation {
                target: welcomeOverlay
                property: "opacity"
                to: 0
                duration: 1500
                easing.type: Easing.OutCubic
            }

            ScriptAction {
                script: welcomeOverlay.visible = false
            }
        }
    }

    // Phase 1, on Enter/Space: the clock flies up and out of the screen while
    // the rest of the greeter fades with it. Held under a second so the key
    // press feels answered immediately; the clock's own fade lands well before
    // the slide does, so nothing is left sitting on screen waiting.
    ParallelAnimation {
        id: slideOut

        NumberAnimation {
            target: shaderBgRoot
            property: "scale"
            to: 1.12
            duration: 900
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: clockWidget
            property: "slideOffsetY"
            to: -root.height
            duration: 400
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: clockWidget
            property: "opacity"
            to: 0
            duration: 400
            easing.type: Easing.InOutCubic
        }

        /*NumberAnimation {
            target: displayWeather
            property: "opacity"
            to: 0
            duration: 450
            easing.type: Easing.InOutCubic
        }*/

        NumberAnimation {
            target: spaceHint
            property: "opacity"
            to: 0
            duration: 380
            easing.type: Easing.InCubic
        }

        onStopped: {
            if (root.transitionState === "login") {
                clockWidget.visible = false;
                //displayWeather.visible = false;
                spaceHint.visible = false;
            }
        }
    }

    // Phase 2: with the clock gone, diffuse what is left and bring the prompt
    // in on top of the blur.
    ParallelAnimation {
        id: blurIn

        NumberAnimation {
            target: backdropBlur
            property: "amount"
            to: 1
            duration: 600
            easing.type: Easing.InOutCubic
        }

        NumberAnimation {
            target: loginPrompt
            property: "opacity"
            to: 1
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    // Esc: undo everything slideOut and blurIn did, in one pass.
    ParallelAnimation {
        id: fadeToMain

        NumberAnimation {
            target: shaderBgRoot
            property: "scale"
            to: 1.0
            duration: 700
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: loginPrompt
            property: "opacity"
            to: 0
            duration: 280
            easing.type: Easing.InOutCubic
        }

        NumberAnimation {
            target: backdropBlur
            property: "amount"
            to: 0
            duration: 450
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: clockWidget
            property: "slideOffsetY"
            to: 0
            duration: 500
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: clockWidget
            property: "opacity"
            to: 1
            duration: 400
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: spaceHint
            property: "opacity"
            to: root.hintDismissed ? 0 : 1
            duration: 400
            easing.type: Easing.OutCubic
        }

        onStopped: {
            if (root.transitionState === "main")
                loginPrompt.visible = false;
        }
    }

    Shortcut {
        sequence: "Ctrl+Space"
        onActivated: keyLangButton.toggleLanguage()
    }

    FocusScope {
        id: keyScope
        anchors.fill: parent
        focus: true

        Keys.onPressed: function (event) {
            if (event.modifiers !== Qt.NoModifier)
                return;

            if (!loginPrompt.visible &&
                (event.key === Qt.Key_Return ||
                 event.key === Qt.Key_Enter ||
                 event.key === Qt.Key_Space)) {

                 root.showLoginPrompt()
                 quickDock.collapse()
                 event.accepted = true
                 return

            } else if (loginPrompt.visible && event.key === Qt.Key_Escape) {
                root.showMain()
                event.accepted = true
            }
        }
    }
}
