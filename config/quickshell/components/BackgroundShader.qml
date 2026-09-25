import QtQuick

Item {
    id: wallpaperRoot
    anchors.fill: parent

    // Ships with the repository. Replace it, or point wallpaperSource at any
    // image, to change the backdrop.
    property url wallpaperSource: Qt.resolvedUrl("../../Wallpapers/default-wallpaper.jpg")

    // Fallback backdrop. The repository only tracks a single compressed
    // wallpaper, so if a user points wallpaperSource at a missing file the
    // greeter still renders a composed background instead of a black screen.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#14141f" }
            GradientStop { position: 0.5; color: "#1e1e2e" }
            GradientStop { position: 1.0; color: "#2a2140" }
        }
    }

    Image {
        anchors.fill: parent
        source: wallpaperRoot.wallpaperSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
    }
}
