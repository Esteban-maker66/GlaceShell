import "../quickshell/components" as GlaceComponent
import QtQuick
import QtQuick.Window

Rectangle {
    id: root

    property string transitionState: "main"

    function showLoginPrompt() {
        transitionState = "login";
        fadeToMain.stop();
        fadeToLogin.stop();
        clockWidget.visible = true;
        displayWeather.visible = true;
        spaceHint.visible = true;
        spaceHint.opacity = 1;
        loginPrompt.visible = true;
        loginPrompt.opacity = 0;
        fadeToLogin.restart();
    }

    function showMain() {
        transitionState = "main";
        fadeToLogin.stop();
        fadeToMain.stop();
        clockWidget.visible = true;
        displayWeather.visible = true;
        spaceHint.visible = true;
        spaceHint.opacity = 0;
        loginPrompt.visible = true;
        clockWidget.opacity = 0;
        displayWeather.opacity = 0;
        fadeToMain.restart();
    }

    width: Screen.width
    height: Screen.height
    color: "#0000002a"

    GlaceComponent.BackgroundShader {
        id: shaderBgRoot

        anchors.fill: parent
    }

    Item {
        id: uiLayer

        anchors.fill: parent

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

        GlaceComponent.LoginPrompt {
            id: loginPrompt
            anchors.centerIn: parent
            visible: false
        }

        GlaceComponent.QuickDock {
            id: quickDock
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 45
            anchors.bottomMargin: 40
        }

        GlaceComponent.BatteryPill {
            id: batteryPill
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 46
            anchors.topMargin: 32
            useSysfs: true
        }

        GlaceComponent.DisplayWeather {
            id: displayWeather
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 32
            anchors.leftMargin: 46

        }

        GlaceComponent.KeyLangBtn {
            id: keyLangButton
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 32
            anchors.bottomMargin: 32
        }
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

    ParallelAnimation {
        id: fadeToLogin

        NumberAnimation {
            target: clockWidget
            property: "opacity"
            to: 0
            duration: 300
            easing.type: Easing.InOutCubic
        }

        NumberAnimation {
            target: displayWeather
            property: "opacity"
            to: 0
            duration: 300
            easing.type: Easing.InOutCubic
        }

        NumberAnimation {
            target: spaceHint
            property: "opacity"
            to: 0
            duration: 300
            easing.type: Easing.InOutCubic
        }

        NumberAnimation {
            target: loginPrompt
            property: "opacity"
            to: 1
            duration: 300
            easing.type: Easing.InOutCubic
        }

        onStopped: {
            if (root.transitionState === "login") {
                clockWidget.visible = false;
                displayWeather.visible = false;
                spaceHint.visible = false;
            }
        }
    }

    ParallelAnimation {
        id: fadeToMain

        NumberAnimation {
            target: loginPrompt
            property: "opacity"
            to: 0
            duration: 300
            easing.type: Easing.InOutCubic
        }

        NumberAnimation {
            target: clockWidget
            property: "opacity"
            to: 1
            duration: 300
            easing.type: Easing.InOutCubic
        }

        NumberAnimation {
            target: displayWeather
            property: "opacity"
            to: 1
            duration: 300
            easing.type: Easing.InOutCubic
        }

        NumberAnimation {
            target: spaceHint
            property: "opacity"
            to: 1
            duration: 300
            easing.type: Easing.InOutCubic
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
