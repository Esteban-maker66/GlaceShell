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
    property string bridgeUrl: "http://127.0.0.1:18765"

    // Network state. Bluetooth is intentionally disabled until its backend
    // integration is added and tested.
    property bool wifiAvailable: false
    property bool wifiConnected: false
    property bool wifiEnabled: false
    property int wifiSignal: 0
    property bool ethernetAvailable: false
    property bool ethernetConnected: false
    property bool bluetoothFeatureEnabled: false
    property bool bluetoothAvailable: false
    readonly property bool bluetoothEnabled: bluetoothFeatureEnabled && bluetoothAvailable
    property bool _networkRequestPending: false

    readonly property int wifiBars: wifiSignal >= 75 ? 3
        : wifiSignal >= 50 ? 2
        : wifiSignal >= 25 ? 1
        : 0
    readonly property string wifiIconSource: wifiEnabled && wifiConnected
        ? iconBase + "/network/wifi-" + wifiBars + ".svg"
        : iconBase + "/network/wifi-0.svg"

    signal suspendRequested()
    signal restartRequested()
    signal powerRequested()

    function requestNetworkState() {
        if (_networkRequestPending)
            return

        _networkRequestPending = true
        var xhr = new XMLHttpRequest()
        xhr.open("GET", bridgeUrl + "/network", true)
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return

            dockContainer._networkRequestPending = false
            if (xhr.status === 200)
                applyNetworkState(xhr.responseText)
        }
        xhr.send()
    }

    function applyNetworkState(output) {
        try {
            var state = JSON.parse(output)
            var wifi = state.wifi || {}
            var ethernet = state.ethernet || {}
            var bluetooth = state.bluetooth || {}

            wifiAvailable = wifi.available === true
            wifiConnected = wifi.connected === true
            wifiEnabled = wifi.enabled === true
            wifiSignal = Math.max(0, Math.min(100, parseInt(wifi.signal || 0)))

            ethernetAvailable = ethernet.available === true
            ethernetConnected = ethernet.connected === true
            bluetoothAvailable = bluetooth.available === true
        } catch (error) {
            console.warn("Could not read the network state:", error)
        }
    }

    function sendNetworkCommand(action) {
        if (_networkRequestPending)
            return

        _networkRequestPending = true
        var xhr = new XMLHttpRequest()
        xhr.open("POST", bridgeUrl + "/network", true)
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return

            dockContainer._networkRequestPending = false
            if (xhr.status === 200)
                applyNetworkState(xhr.responseText)
        }
        xhr.send(JSON.stringify({ "action": action }))
    }

    function toggleWifi() {
        if (wifiAvailable)
            sendNetworkCommand("toggleWifi")
    }

    function toggleEthernet() {
        if (ethernetAvailable)
            sendNetworkCommand("toggleEthernet")
    }

    Timer {
        id: hideTimer
        interval: 450
        onTriggered: dockContainer.animating = false
    }

    Timer {
        id: networkTimer
        interval: 5000
        repeat: true
        running: true
        onTriggered: dockContainer.requestNetworkState()
    }

    Component.onCompleted: requestNetworkState()

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
            visible: dockContainer.bluetoothEnabled && (dockContainer.expanded || dockContainer.animating)
            property real entryOffset: 0
            transform: Translate { y: loaderBT.entryOffset }

            onLoaded: {
                if (item)
                    item.btOn = true
            }

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
        Item {
            id: loaderWifi
            width: 42; height: 42
            opacity: 0
            visible: dockContainer.wifiAvailable && (dockContainer.expanded || dockContainer.animating)
            property real entryOffset: 0
            transform: Translate { y: loaderWifi.entryOffset }

            Connections {
                target: dockContainer

                function onWifiAvailableChanged() {
                    if (dockContainer.wifiAvailable && dockContainer.expanded)
                        entryWifi.restart()
                }
            }

            Image {
                id: wifiImage
                anchors.fill: parent
                source: dockContainer.wifiIconSource
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
            }

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
                    dockContainer.toggleWifi()
                }
            }
        }

        // Ethernet
        Loader {
            id: loaderEth
            width: 42; height: 42
            source: dockContainer.iconBase + "/network/ethernet.qml"
            opacity: 0
            visible: dockContainer.ethernetAvailable && (dockContainer.expanded || dockContainer.animating)
            property real entryOffset: 0
            transform: Translate { y: loaderEth.entryOffset }

            onLoaded: {
                if (item)
                    item.connected = dockContainer.ethernetConnected
            }

            Connections {
                target: dockContainer

                function onEthernetAvailableChanged() {
                    if (dockContainer.ethernetAvailable && dockContainer.expanded)
                        entryEth.restart()
                }

                function onEthernetConnectedChanged() {
                    if (loaderEth.item)
                        loaderEth.item.connected = dockContainer.ethernetConnected
                }
            }

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
                    dockContainer.toggleEthernet()
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
            onClicked: dockContainer.suspendRequested()

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
            onClicked: dockContainer.restartRequested()

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
            onClicked: dockContainer.powerRequested()

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
