import QtQuick

Item {
    id: weatherIcon

    property string condition: "sun"

    function iconSource() {
        return Qt.resolvedUrl("../assets/icons/WeatherIcons/weather-" + condition + ".svg");
    }

    Image {
        id: iconImage
        anchors.fill: parent
        source: weatherIcon.iconSource()
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
        transformOrigin: Item.Center

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
    }

    SequentialAnimation {
        id: iconTransition
        running: false

        NumberAnimation {
            target: iconImage
            property: "scale"
            to: 0.82
            duration: 90
            easing.type: Easing.InQuad
        }

        NumberAnimation {
            target: iconImage
            property: "scale"
            to: 1
            duration: 180
            easing.type: Easing.OutBack
        }
    }

    onConditionChanged: iconTransition.restart()
}
