import QtQuick
import QtQuick.Effects

Item {
    id: clockWidget
    width: clockColumn.implicitWidth
    height: clockColumn.implicitHeight

    property real horizontalPosition: 0.5
    property real verticalPosition: 0.5
    property real dateHorizontalOffset: 0
    property real dateVerticalOffset: 0

    x: parent ? (parent.width - width) * horizontalPosition : 0
    y: parent ? (parent.height - height) * verticalPosition : 0

    property string timeString: ""
    property string dateString: ""

    FontLoader {
        id: konkhmer
        source: Qt.resolvedUrl("../../fonts/KonkhmerSleokchher-Regular.ttf")
    }

    FontLoader {
        id: estedad
        source: Qt.resolvedUrl("../../fonts/Estedad-VF.ttf")
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    Column {
        id: clockColumn
        anchors.centerIn: parent
        spacing: 4

        Item {
            id: timeDisplay
            width: timeText.implicitWidth
            height: timeText.implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: timeText
                anchors.fill: parent
                text: clockWidget.timeString
                font.pixelSize: 190
                font.family: konkhmer.name
                color: "#FFFFFF"
                styleColor: "#6c000000"
                visible: false
                renderType: Text.NativeRendering
            }

            MultiEffect {
                anchors.fill: timeText
                source: timeText
                shadowEnabled: true
                shadowColor: "#9f000000"
                shadowBlur: 2
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 2
            }
        }

        Item {
            id: dateDisplay
            width: dateText.implicitWidth
            height: dateText.implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter

            transform: Translate {
                x: clockWidget.dateHorizontalOffset
                y: clockWidget.dateVerticalOffset
            }

            Text {
                id: dateText
                anchors.fill: parent
                text: clockWidget.dateString
                font.pixelSize: 40
                font.family: konkhmer.name
                color: "#FFFFFF"
                style: Text.Raised
                styleColor: "#6c000000"
                font.weight: Font.DemiBold
                visible: false
                renderType: Text.NativeRendering
            }

            MultiEffect {
                anchors.fill: dateText
                source: dateText
                shadowEnabled: true
                shadowColor: "#9f000000"
                shadowBlur: 2
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 2
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var date = new Date();

            var dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
            var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

            var hour12 = date.getHours() % 12;
            if (hour12 === 0)
                hour12 = 12;

            clockWidget.timeString = hour12 + ":" + Qt.formatTime(date, "mm");
            clockWidget.dateString = dayNames[date.getDay()] + ", " + monthNames[date.getMonth()] + " " + date.getDate();
        }
    }
}
