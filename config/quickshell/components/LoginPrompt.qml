import QtQuick
import QtQuick.Effects

// Visual shell for the login view.
//
// The transition into this view (clock sliding out, backdrop blur) lives in
// config/sddm/main.qml. What lives here is only the panel that the blur
// reveals: it is drawn above the blur layer, so it stays sharp while the
// wallpaper behind it is diffused.
//
// STATUS: the panel is not wired to SDDM's login protocol yet. SDDM themes
// authenticate through its UserModel/ login capability, which is a separate
// step. Nothing in here submits credentials.
Item {
    id: loginPrompt

    property bool ready: opacity > 0.01

    implicitWidth: panel.width
    implicitHeight: panel.height

    FontLoader {
        id: promptFont
        source: Qt.resolvedUrl("../../fonts/Estedad-Bold.ttf")
    }

    FontLoader {
        id: promptBodyFont
        source: Qt.resolvedUrl("../../fonts/Estedad-VF.ttf")
    }

    Rectangle {
        id: panel

        width: 380
        height: 208
        radius: 28
        color: "#1b1b1b3d"
        border.width: 1
        border.color: "#ffffff33"

        // Soft drop shadow so the panel separates from the blurred backdrop.
        MultiEffect {
            anchors.fill: panel
            source: panel
            shadowEnabled: true
            shadowColor: "#6c000000"
            shadowBlur: 24
            shadowHorizontalOffset: 0
            shadowVerticalOffset: 8
        }

        Column {
            anchors.centerIn: parent
            width: parent.width - 48
            spacing: 14

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Iniciar sesión"
                color: "#FFFFFF"
                font.family: promptFont.name
                font.pixelSize: 19
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: "El acceso se conectará al protocolo de SDDM en una etapa posterior."
                color: "#efefef"
                opacity: 0.7
                font.family: promptBodyFont.name
                font.pixelSize: 13
            }
        }
    }
}
