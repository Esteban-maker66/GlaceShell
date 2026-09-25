import QtQuick

Item {
	id: keyLangBtn

	property string language: "es"
	property string label: language === "es" ? "ESP" : "ENG"
	property int textPixelSize: 20
	property color textColor: "#efefef"
	property bool busy: false

	implicitWidth: 54
	implicitHeight: 30

	FontLoader {
		id: estedad
		// Estedad-VF defaults to Thin/Regular; use the static bold face for this label.
		source: Qt.resolvedUrl("../../fonts/Estedad-Bold.ttf")
	}

	function toggleLanguage() {
		if (busy)
			return;

		var nextLanguage = language === "es" ? "en" : "es";
		var xhr = new XMLHttpRequest();
		xhr.open("POST", "http://127.0.0.1:18765/keyboard", true);
		xhr.setRequestHeader("Content-Type", "application/json");
		busy = true;
		xhr.onreadystatechange = function() {
			if (xhr.readyState !== XMLHttpRequest.DONE)
				return;

			busy = false;
			if (xhr.status === 200) {
				language = nextLanguage;
				labelFade.restart();
			} else {
				console.warn("Could not change the keyboard language:", xhr.responseText);
			}
		};
		xhr.send(JSON.stringify({ "layout": nextLanguage === "es" ? "es" : "us" }));
	}

	Text {
		id: languageLabel
		anchors.fill: parent
		text: keyLangBtn.label
		color: keyLangBtn.textColor
		font.family: estedad.name
		font.pixelSize: keyLangBtn.textPixelSize
		font.weight: Font.Bold
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		renderType: Text.NativeRendering
		opacity: 1

		Behavior on scale {
			NumberAnimation {
				duration: 100
				easing.type: Easing.OutCubic
			}
		}
	}

	SequentialAnimation {
		id: labelFade

		NumberAnimation {
			target: languageLabel
			property: "opacity"
			to: 0
			duration: 10
			easing.type: Easing.InCubic
		}

		NumberAnimation {
			target: languageLabel
			property: "opacity"
			to: 1
			duration: 10
			easing.type: Easing.OutCubic
		}
	}

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true

		onPressed: languageLabel.scale = 0.9
		onReleased: languageLabel.scale = 1
		onCanceled: languageLabel.scale = 1
		onClicked: keyLangBtn.toggleLanguage()
	}

}
