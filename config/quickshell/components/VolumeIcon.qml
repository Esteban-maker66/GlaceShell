import QtQuick

Item {
    id: volumeIcon

    property real level: 0.65
    property bool muted: false
    property int pulsePadding: 0
    readonly property string iconName: muted ? "muted" : level <= 0.4 ? "low" : level <= 0.7 ? "medium" : "high"

    function assetLevel() {
        return iconName === "muted" ? "mute" : iconName;
    }

    Loader {
        id: iconLoader
        anchors.fill: parent
        anchors.margins: volumeIcon.pulsePadding
        source: Qt.resolvedUrl("../assets/icons/VolumeIcon.qml")

        function updateIcon() {
            if (!item)
                return;

            item.level = volumeIcon.assetLevel();
            item.color = "#000000";
            item.size = Math.min(width, height);
            item.autoPlay = false;
            item.play();
        }

        onLoaded: updateIcon()
    }

    onIconNameChanged: {
        iconLoader.updateIcon();
    }
}
