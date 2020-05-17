import QtQuick 2.1
import qb.components 1.0

Tile {
	property string demoDir

	function init() {
		demoDir = widgetArgs.config.demoDir;
		tileTitle.text = app.getDemoTitle(demoDir);
		tileImage.source = demoDir + "/tileImage.png";
	}

	onClicked: {
		app.showDemo(demoDir);
	}

	Text {
		id: tileTitle
		color: dimmableColors.tileTitleColor
		anchors {
			baseline: parent.top
			baselineOffset: 28
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: qfont.tileTitle
		horizontalAlignment: Text.AlignLeft
		verticalAlignment: Text.AlignTop
		font.family: qfont.regular.name
	}

	Image {
		id: tileImage
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: tileText.top
		}
	}

	Text {
		id: tileText
		text: qsTr("Demo")
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
}
