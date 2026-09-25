import QtQuick 2.15
import QtQuick.Controls 2.15
import "../config/quickshell/components" as Custom

Rectangle {
    width: 1920
    height: 1080
    color: "#1e1e2e"

    Custom.ClockWidget {
        anchors.centerIn: parent
    }

    Custom.TopVolumeBar {
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Custom.QuickDock {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // 100% - Normal state
    Custom.BatteryPill {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 46
        anchors.topMargin: 32
        useSysfs: false
        level: 100
        charging: false
        powerSaving: false
    }

    // 50% - Charging
    Custom.BatteryPill {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 46
        anchors.topMargin: 100
        useSysfs: false
        level: 50
        charging: true
        powerSaving: false
    }

    // 21% - Low battery
    Custom.BatteryPill {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 46
        anchors.topMargin: 168
        useSysfs: false
        level: 20
        charging: false
        powerSaving: false
    }

    // 30% - Power saving
    Custom.BatteryPill {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 46
        anchors.topMargin: 236
        useSysfs: false
        level: 30
        charging: false
        powerSaving: true
    }

    // 10% - Very low level (checks the clamped fill radius)
    Custom.BatteryPill {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 46
        anchors.topMargin: 304
        useSysfs: false
        level: 10
        charging: false
        powerSaving: false
    }

    // 5% - Minimum visible level
    Custom.BatteryPill {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 46
        anchors.topMargin: 372
        useSysfs: false
        level: 5
        charging: false
        powerSaving: false
    }
}
