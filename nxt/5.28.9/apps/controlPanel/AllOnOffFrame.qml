import QtQuick 2.1
import qb.components 1.0

WizardFrame {

	function initWizardFrame() {
		allOnOffToggle.positionIsLeft = app.addToAllOnOff === 1;
		allOnOffLabel.enabled = !app.switchLocked;
	}

	title: qsTr("Add to Group")
	nextPage: 4

	Text {
		id: text
		anchors {
			top: parent.top
			topMargin: Math.round(79 * verticalScaling)
			left: allOnOffLabel.left
			right: allOnOffLabel.right
		}
		text: qsTr("all_on_off_text")
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors.plugTabText
		wrapMode: Text.WordWrap
	}

	SingleLabel {
		id: allOnOffLabel

		width: Math.round(533 * horizontalScaling)
		leftText: qsTr("add to Group")
		rightText: ""
		iconSource: "image://scaled/apps/controlPanel/drawables/group" + (!enabled ? "_disabled" : "") + ".svg"

		anchors {
			top: text.bottom
			topMargin: Math.round(40 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}

		OptionToggle {
			id: allOnOffToggle

			enabled: parent.enabled
			leftText: qsTr("Yes")
			rightText: qsTr("No")
			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.right
				rightMargin: Math.round(13 * horizontalScaling)
			}
			onPositionIsLeftChanged: {
				app.addToAllOnOff = positionIsLeft ? 1 : 0;
			}
		}
	}
}
