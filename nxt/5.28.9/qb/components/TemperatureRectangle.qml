import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;

StyledRectangle {
	id: root
	width: Math.round(114 * horizontalScaling)
	height: Math.round(65 * verticalScaling)

	property string kpiPostfix: subLabelText
	property alias subLabelText: subLabel.text
	property int stateId: -1
	property real temperature: 0
	property bool selected: false
	radius: designElements.radius
	topLeftRadiusRatio: 0
	topRightRadiusRatio: 0
	bottomLeftRadiusRatio: 0
	bottomRightRadiusRatio: 0
	borderWidth: 1
	borderColor: colors.tempTileBorderUp
	borderStyle: Qt.SolidLine

	mouseIsActiveInDimState: true

	Text {
		id: subLabel
		anchors.verticalCenter: parent.verticalCenter
		anchors.horizontalCenter: parent.horizontalCenter
		font.family: qfont.semiBold.name
		font.pixelSize: qfont.tileTitle
	}

	state: "up"

	states: [
		State {
			name: "up"
			PropertyChanges { target: root;     color: colors.tempTileBackgroundUp }
			PropertyChanges { target: root;     borderColor: colors.tempTileBorderUp }
			PropertyChanges { target: subLabel; color: colors.tempTileTextUp }
		},
		State {
			name: "down"
			PropertyChanges { target: root;     color: colors.tempTileBackgroundDown }
			PropertyChanges { target: root;     borderColor: colors.tempTileBorderDown }
			PropertyChanges { target: subLabel; color: colors.tempTileTextDown }
		},
		State {
			name: "unselected"
			PropertyChanges { target: root;     color: colors.tempTileBackgroundUp }
			PropertyChanges { target: root;     borderColor: colors.tempTileBorderUp }
			PropertyChanges { target: subLabel; color: colors.tempTileTextUp }
		},
		State {
			name: "selected"
			PropertyChanges { target: root;     color: colors.tempTileBackgroundDown }
			PropertyChanges { target: root;     borderColor: colors.tempTileBorderDown }
			PropertyChanges { target: subLabel; color: colors.tempTileTextDown }
		},
		State {
			name: "disabled"
			PropertyChanges { target: root;     color: colors.tempTileBackgroundDown }
			PropertyChanges { target: root;     borderColor: colors.tempTileBorderDown }
			PropertyChanges { target: subLabel; color: "lightgray" }
		}
	]

	onSelectedChanged: {
		if (selected) {
			root.state = "selected"
		} else {
			root.state = "unselected"
		}
	}

	onEnabledChanged: {
		if (!enabled) {
			root.state = "disabled"
		}
		else {
			if (selected) {
				root.state = "selected"
			} else {
				root.state = "unselected"
			}
		}
	}
}
