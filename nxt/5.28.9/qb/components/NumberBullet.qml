import QtQuick 2.1

RoundedRectangle {
	id: nb
	color: colors.numberBullet
	property int size: Math.round(25 * verticalScaling)
	property alias text: nbText.text

	width: size
	height: size
	radius: Math.round(size / 2)

	Text {
		id: nbText
		anchors {
			centerIn: parent
			verticalCenterOffset: -1
		}
		font {
			family: qfont.bold.name
			pixelSize: nb.width / 5 * 3
		}
		color: colors.numberBulletText
	}

	states: [
		State {
			name: "disabled"
			when: nb.enabled === false
			PropertyChanges { target: nb; color: colors.numberBulletDisabled }
		}
	]
}
