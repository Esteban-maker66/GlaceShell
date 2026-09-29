import QtQuick
import QtQuick.Effects

// Native Gaussian blur over another item's content.
//
// The target keeps its own visibility: MultiEffect renders the captured,
// blurred result on top of it, and because the output is opaque it covers
// the sharp original. That avoids the fragile "hide the source" dance, since
// capture behaviour of a hidden source is not something to rely on.
//
// The blur is drawn by Qt's native effect backend, which compiles to a GLSL
// fragment shader and runs on the GPU. Hand-writing a ShaderEffect for this
// would add code, lose the hardware path, and gain nothing visually.
Item {
    id: generalBlur

    // Item whose content gets blurred. Usually the layer holding the backdrop.
    property Item target

    // Maximum blur radius in pixels. `amount` scales between 0 and this.
    property real radius: 48

    // 0 = no blur at all, 1 = full radius. Animate this.
    property real amount: 0

    // At amount 0 the effect is skipped entirely rather than drawn transparent,
    // so an inactive blur costs nothing.
    visible: amount > 0.001

    MultiEffect {
        anchors.fill: parent
        source: generalBlur.target

        blurEnabled: true
        blur: generalBlur.amount
        blurMax: generalBlur.radius
    }
}
