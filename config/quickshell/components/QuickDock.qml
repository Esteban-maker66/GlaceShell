import QtQuick
import QtQuick.Effects

Item {
    id: dockContainer
    width: 42
    height: iconColumn.height
    property bool expanded: false
    property bool animating: false
    property real lastClickTime: 0

    readonly property string iconBase: Qt.resolvedUrl("../assets/icons/QuickDockIcons")

    Timer {
        id: hideTimer
        interval: 450
        onTriggered: dockContainer.animating = false
    }

    function expand() {
        animating = true
        entryBT.start()
        entryWifi.start()
        entryEth.start()
        entrySuspend.start()
        entryRestart.start()
        entryPower.start()
    }

    function collapse() {
        if (!expanded) return
        expanded = false
        animating = true
        hideTimer.restart()
        exitBT.start()
        exitWifi.start()
        exitEth.start()
        exitSuspend.start()
        exitRestart.start()
        exitPower.start()
    }

    Column {
        id: iconColumn
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 24

        // Bluetooth (top)
        Loader {
            id: loaderBT
            width: 42; height: 42
            source: dockContainer.iconBase + "/bt/Bluetooth.qml"
            opacity: 0
            visible: dockContainer.expanded || dockContainer.animating
            property real entryOffset: 0
            layer.enabled: true
            layer.samples: 4
            transform: Translate { y: loaderBT.entryOffset }

            onLoaded: { item.btOn = true }

            SequentialAnimation {
                id: entryBT
                PropertyAnimation { target: loaderBT; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
                ParallelAnimation {
                    PropertyAnimation { target: loaderBT; property: "entryOffset"; from: 15; to: 0; duration: 350; easing.type: Easing.OutBack }
                }
            }

            SequentialAnimation {
                id: exitBT
                PauseAnimation { duration: 0 }
                PropertyAnimation { target: loaderBT; property: "entryOffset"; to: 15; duration: 250; easing.type: Easing.InCubic }
                PropertyAnimation { target: loaderBT; property: "opacity"; to: 0; duration: 150; easing.type: Easing.OutCubic }
            }

            SequentialAnimation {
                id: bounceBT
                PauseAnimation { duration: 0 }
                PropertyAnimation { target: loaderBT; property: "scale"; to: 1.15; duration: 120; easing.type: Easing.OutQuad }
                PropertyAnimation { target: loaderBT; property: "scale"; to: 0.95; duration: 90; easing.type: Easing.InOutQuad }
                PropertyAnimation { target: loaderBT; property: "scale"; to: 1.0; duration: 90; easing.type: Easing.OutCubic }
            }

            SequentialAnimation {
                id: pulseBT
                PropertyAnimation { target: loaderBT; property: "scale"; to: 0.92; duration: 50; easing.type: Easing.OutQuad }
                PropertyAnimation { target: loaderBT; property: "scale"; to: 1.0; duration: 70; easing.type: Easing.OutCubic }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    pulseBT.start()
                    if (loaderBT.item) loaderBT.item.toggle()
                }
            }
        }

        // WiFi
        Loader {
            id: loaderWifi
            width: 42; height: 42
            source: dockContainer.iconBase + "/network/wifi-off.qml"
            opacity: 0
            visible: dockContainer.expanded || dockContainer.animating
            property real entryOffset: 0
            layer.enabled: true
            layer.samples: 4
            transform: Translate { y: loaderWifi.entryOffset }

            onLoaded: { item.wifiOn = true }

            SequentialAnimation {
                id: entryWifi
                PauseAnimation { duration: 60 }
                PropertyAnimation { target: loaderWifi; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
                ParallelAnimation {
                    PropertyAnimation { target: loaderWifi; property: "entryOffset"; from: 15; to: 0; duration: 320; easing.type: Easing.OutBack }
                }
            }

            SequentialAnimation {
                id: exitWifi
                PauseAnimation { duration: 60 }
                PropertyAnimation { target: loaderWifi; property: "entryOffset"; to: 15; duration: 250; easing.type: Easing.InCubic }
                PropertyAnimation { target: loaderWifi; property: "opacity"; to: 0; duration: 150; easing.type: Easing.OutCubic }
            }

            SequentialAnimation {
                id: bounceWifi
                PauseAnimation { duration: 60 }
                PropertyAnimation { target: loaderWifi; property: "scale"; to: 1.15; duration: 120; easing.type: Easing.OutQuad }
                PropertyAnimation { target: loaderWifi; property: "scale"; to: 0.95; duration: 90; easing.type: Easing.InOutQuad }
                PropertyAnimation { target: loaderWifi; property: "scale"; to: 1.0; duration: 90; easing.type: Easing.OutCubic }
            }

            SequentialAnimation {
                id: pulseWifi
                PropertyAnimation { target: loaderWifi; property: "scale"; to: 0.92; duration: 50; easing.type: Easing.OutQuad }
                PropertyAnimation { target: loaderWifi; property: "scale"; to: 1.0; duration: 70; easing.type: Easing.OutCubic }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    pulseWifi.start()
                    if (loaderWifi.item) loaderWifi.item.toggle()
                }
            }
        }

        // Ethernet
        Loader {
            id: loaderEth
            width: 42; height: 42
            source: dockContainer.iconBase + "/network/ethernet.qml"
            opacity: 0
            visible: dockContainer.expanded || dockContainer.animating
            property real entryOffset: 0
            layer.enabled: true
            layer.samples: 4
            transform: Translate { y: loaderEth.entryOffset }

            onLoaded: { item.connected = true }

            SequentialAnimation {
                id: entryEth
                PauseAnimation { duration: 120 }
                PropertyAnimation { target: loaderEth; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
                ParallelAnimation {
                    PropertyAnimation { target: loaderEth; property: "entryOffset"; from: 15; to: 0; duration: 290; easing.type: Easing.OutBack }
                }
            }

            SequentialAnimation {
                id: exitEth
                PauseAnimation { duration: 120 }
                PropertyAnimation { target: loaderEth; property: "entryOffset"; to: 15; duration: 250; easing.type: Easing.InCubic }
                PropertyAnimation { target: loaderEth; property: "opacity"; to: 0; duration: 150; easing.type: Easing.OutCubic }
            }

            SequentialAnimation {
                id: bounceEth
                PauseAnimation { duration: 120 }
                PropertyAnimation { target: loaderEth; property: "scale"; to: 1.15; duration: 120; easing.type: Easing.OutQuad }
                PropertyAnimation { target: loaderEth; property: "scale"; to: 0.95; duration: 90; easing.type: Easing.InOutQuad }
                PropertyAnimation { target: loaderEth; property: "scale"; to: 1.0; duration: 90; easing.type: Easing.OutCubic }
            }

            SequentialAnimation {
                id: pulseEth
                PropertyAnimation { target: loaderEth; property: "scale"; to: 0.92; duration: 50; easing.type: Easing.OutQuad }
                PropertyAnimation { target: loaderEth; property: "scale"; to: 1.0; duration: 70; easing.type: Easing.OutCubic }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    pulseEth.start()
                    if (loaderEth.item) loaderEth.item.toggle()
                }
            }
        }

        // Suspend
        DockIcon {
            id: iconSuspend
            source: dockContainer.iconBase + "/suspend.svg"
            opacity: 0
            visible: dockContainer.expanded || dockContainer.animating
            property real entryOffset: 0
            transform: Translate { y: iconSuspend.entryOffset }
            onClicked: console.log("suspend")

            SequentialAnimation {
                id: entrySuspend
                PauseAnimation { duration: 180 }
                PropertyAnimation { target: iconSuspend; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
                ParallelAnimation {
                    PropertyAnimation { target: iconSuspend; property: "entryOffset"; from: 15; to: 0; duration: 260; easing.type: Easing.OutBack }
                }
            }

            SequentialAnimation {
                id: exitSuspend
                PauseAnimation { duration: 180 }
                PropertyAnimation { target: iconSuspend; property: "entryOffset"; to: 15; duration: 250; easing.type: Easing.InCubic }
                PropertyAnimation { target: iconSuspend; property: "opacity"; to: 0; duration: 150; easing.type: Easing.OutCubic }
            }

            SequentialAnimation {
                id: bounceSuspend
                PauseAnimation { duration: 180 }
                PropertyAnimation { target: iconSuspend; property: "scale"; to: 1.15; duration: 120; easing.type: Easing.OutQuad }
                PropertyAnimation { target: iconSuspend; property: "scale"; to: 0.95; duration: 90; easing.type: Easing.InOutQuad }
                PropertyAnimation { target: iconSuspend; property: "scale"; to: 1.0; duration: 90; easing.type: Easing.OutCubic }
            }
        }

        // Restart
        DockIcon {
            id: iconRestart
            source: dockContainer.iconBase + "/restart.svg"
            opacity: 0
            visible: dockContainer.expanded || dockContainer.animating
            property real entryOffset: 0
            transform: Translate { y: iconRestart.entryOffset }
            onClicked: console.log("restart")

            SequentialAnimation {
                id: entryRestart
                PauseAnimation { duration: 240 }
                PropertyAnimation { target: iconRestart; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
                ParallelAnimation {
                    PropertyAnimation { target: iconRestart; property: "entryOffset"; from: 15; to: 0; duration: 230; easing.type: Easing.OutBack }
                }
            }

            SequentialAnimation {
                id: exitRestart
                PauseAnimation { duration: 240 }
                PropertyAnimation { target: iconRestart; property: "entryOffset"; to: 15; duration: 250; easing.type: Easing.InCubic }
                PropertyAnimation { target: iconRestart; property: "opacity"; to: 0; duration: 150; easing.type: Easing.OutCubic }
            }

            SequentialAnimation {
                id: bounceRestart
                PauseAnimation { duration: 240 }
                PropertyAnimation { target: iconRestart; property: "scale"; to: 1.15; duration: 120; easing.type: Easing.OutQuad }
                PropertyAnimation { target: iconRestart; property: "scale"; to: 0.95; duration: 90; easing.type: Easing.InOutQuad }
                PropertyAnimation { target: iconRestart; property: "scale"; to: 1.0; duration: 90; easing.type: Easing.OutCubic }
            }
        }

        // Power
        DockIcon {
            id: iconPower
            source: dockContainer.iconBase + "/power.svg"
            opacity: 0
            visible: dockContainer.expanded || dockContainer.animating
            property real entryOffset: 0
            transform: Translate { y: iconPower.entryOffset }
            onClicked: console.log("power")

            SequentialAnimation {
                id: entryPower
                PauseAnimation { duration: 300 }
                PropertyAnimation { target: iconPower; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
                ParallelAnimation {
                    PropertyAnimation { target: iconPower; property: "entryOffset"; from: 15; to: 0; duration: 200; easing.type: Easing.OutBack }
                }
            }

            SequentialAnimation {
                id: exitPower
                PauseAnimation { duration: 300 }
                PropertyAnimation { target: iconPower; property: "entryOffset"; to: 15; duration: 250; easing.type: Easing.InCubic }
                PropertyAnimation { target: iconPower; property: "opacity"; to: 0; duration: 150; easing.type: Easing.OutCubic }
            }

            SequentialAnimation {
                id: bouncePower
                PauseAnimation { duration: 300 }
                PropertyAnimation { target: iconPower; property: "scale"; to: 1.15; duration: 120; easing.type: Easing.OutQuad }
                PropertyAnimation { target: iconPower; property: "scale"; to: 0.95; duration: 90; easing.type: Easing.InOutQuad }
                PropertyAnimation { target: iconPower; property: "scale"; to: 1.0; duration: 90; easing.type: Easing.OutCubic }
            }
        }

        // Arch logo (bottom)
        Item {
            width: 42; height: 42

            Image {
                id: archSource
                anchors.fill: parent
                source: Qt.resolvedUrl("../assets/icons/extraIcons/Arch.svg")
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                visible: false
            }

            Item {
                id: archVisual
                anchors.fill: parent
                rotation: dockContainer.expanded ? 180 : 0

                MultiEffect {
                    anchors.fill: parent
                    source: archSource
                    shadowEnabled: true
                    shadowColor: "#b1000002"
                    shadowBlur: 2
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 2
                }

                SequentialAnimation {
                    id: pulseArch
                    PropertyAnimation { target: archVisual; property: "scale"; to: 0.92; duration: 50; easing.type: Easing.OutQuad }
                    PropertyAnimation { target: archVisual; property: "scale"; to: 1.0; duration: 70; easing.type: Easing.OutCubic }
                }

                Behavior on rotation {
                    NumberAnimation { duration: 320; easing.type: Easing.OutBack }
                }

                MouseArea {
                    id: archHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        var now = Date.now()
                        if (now - dockContainer.lastClickTime < 600) return
                        dockContainer.lastClickTime = now

                        pulseArch.start()
                        if (dockContainer.expanded) {
                            dockContainer.collapse()
                        } else {
                            dockContainer.expanded = true
                            dockContainer.expand()
                            bounceBT.start()
                            bounceWifi.start()
                            bounceEth.start()
                            bounceSuspend.start()
                            bounceRestart.start()
                            bouncePower.start()
                        }
                    }
                }
            }
        }
    }

    // Reusable icon component
    component DockIcon: Item {
        id: dockIconRoot
        width: 42; height: 42
        property string source
        signal clicked()

        Image {
            id: iconImage
            anchors.fill: parent
            source: dockIconRoot.source
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
        }

        SequentialAnimation {
            id: pulseIcon
            PropertyAnimation { target: dockIconRoot; property: "scale"; to: 0.92; duration: 80; easing.type: Easing.OutQuad }
            PropertyAnimation { target: dockIconRoot; property: "scale"; to: 1.0; duration: 120; easing.type: Easing.OutCubic }
        }

        MouseArea {
            id: iconMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                pulseIcon.start()
                dockIconRoot.clicked()
            }
        }
    }
}
