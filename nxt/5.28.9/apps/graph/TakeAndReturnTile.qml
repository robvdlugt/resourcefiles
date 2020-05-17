import QtQuick 2.1
import qb.components 1.0

Tile {
	id: takeAndReturnTile

	QtObject {
		id: p
		property color currentDotColor: taking ? dimmableColors.takeAndReturnDotTaking : dimmableColors.takeAndReturnDotFeeding
		property int smallDotSize: Math.round(5 * verticalScaling)
		property int middleDotSize: Math.round(10 * verticalScaling)
		property int bigDotSize: Math.round(15 * verticalScaling)
		property bool taking: true
		property int animationState: 0

		function update() {
			var value = app.powerUsageData.value;
			var valueSolar = app.powerUsageData.valueSolar;
			var amountTaking = value - valueSolar
			if (isNaN(value) || isNaN(valueSolar) || amountTaking === 0) {
				animationTimer.stop();
				taking = true;
				tileText.text  = (isNaN(value) || isNaN(valueSolar)) ? '-' : '0 Watt';
				dot0.visible = dot1.visible = dot2.visible =  false;
				return;
			}
			animationTimer.restart();
			tileText.text = i18n.number(Math.abs(amountTaking), 0) + ' Watt';
			if (taking !== (value > valueSolar)) {
				dot0.visible = dot1.visible = dot2.visible = false;
				taking = !taking;
				animationState = 0;
			}
			if (!taking && (amountTaking < 0)) {
				dot0.height = smallDotSize;
				dot2.height = bigDotSize;
			} else if (taking && (amountTaking > 0)) {
				dot0.height = bigDotSize;
				dot2.height = smallDotSize;
			}
		}

		function nextAnimationStep() {
			if (!taking) {
				switch (animationState) {
				case 0:
					dot0.visible = true;
					break;
				case 1:
					dot1.visible = true;
					break;
				case 2:
					dot2.visible = true;
					break;
				case 3:
					dot0.visible = dot1.visible = dot2.visible = false;
					break;
				}
			} else {
				switch (animationState) {
				case 0:
					dot2.visible = true;
					break;
				case 1:
					dot1.visible = true;
					break;
				case 2:
					dot0.visible = true;
					break;
				case 3:
					dot0.visible = dot1.visible = dot2.visible = false;
					break;
				}
			}
			animationState = (++animationState) % 4;
		}
	}

	function init() {
		if (app.powerUsageDataRead)
			p.update();
		app.powerUsageDataChanged.connect(p.update);
	}

	Component.onDestruction: {
		app.powerUsageDataChanged.disconnect(p.update);
	}

	onClicked: {
		stage.openFullscreen(app.graphScreenUrl, {agreementType: 'electricity', unitType: "energy", intervalType: "hours", consumption: true, production: true})
	}

	Text {
		id: tileTitle

		text: p.taking ? qsTr("Take") : qsTr("Return")

		anchors {
			baseline: parent.top
			baselineOffset: 30
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: dimmableColors.tileTitleColor
	}

	Image {
		id: mastImage
		source: "image://scaled/apps/graph/drawables/mast.svg"
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: Math.round(41 * verticalScaling)
		}
	}

	Rectangle {
		id: dot2
		color: p.currentDotColor
		width: height
		radius: height / 2
		visible: false
		anchors {
			verticalCenter: mastImage.verticalCenter
			right: mastImage.left
			rightMargin: designElements.hMargin10
		}
	}
	Rectangle {
		id: dot1
		height: p.middleDotSize
		width: height
		radius: height / 2
		color: p.currentDotColor
		visible: false
		anchors {
			verticalCenter: dot2.verticalCenter
			right: dot2.left
			rightMargin: designElements.hMargin5
		}
	}
	Rectangle {
		id: dot0
		color: p.currentDotColor
		width: height
		radius: height / 2
		visible: false
		anchors {
			verticalCenter: dot1.verticalCenter
			right: dot1.left
			rightMargin: designElements.hMargin5
		}
	}

	Text {
		id: tileText
		text: '- Watt'
		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
		}
		verticalAlignment: Text.AlignBottom
		horizontalAlignment: Text.AlignRight
		font.pixelSize: qfont.tileText
		font.family: qfont.regular.name
		color: dimmableColors.tileTextColor
	}

	Timer {
		id: animationTimer
		interval: 500
		repeat: true
		running: false
		onTriggered: { p.nextAnimationStep(); }
	}
}
