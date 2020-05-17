import QtQuick 2.1
import qb.base 1.0
import BasicUIControls 1.0;

import qb.components 1.0

BenchmarkWizardFrame {
	id: surfaceAreaFrame

	property int selectedHouseType: 5

	outcomeData: surfaceAreaSpinner.value

	QtObject {
		id: p

		property variant mapping: [
			{defSurface: 70, name: qsTr("apartment")},
			{defSurface: 155, name: qsTr("detached")},
			{defSurface: 125, name: qsTr("semi-detached")},
			{defSurface: 110, name: qsTr("corner house")},
			{defSurface: 110, name: qsTr("row house")},
			{defSurface: 105, name: qsTr("flat")}]
	}

	function setSurfaceArea(value) {
		surfaceAreaSpinner.value = value;
	}

	function getSurfaceArea() {
		return surfaceAreaSpinner.value;
	}

	function getFrameData() {
		return {type: wizardScreen.outcomeData[0], size: outcomeData};
	}

	function initWizardFrame(args) {
		selectedHouseType = wizardScreen.outcomeData[0];
		if (args !== undefined && args.type === selectedHouseType) {
			surfaceAreaSpinner.value = args.size;
		} else {
			surfaceAreaSpinner.value = p.mapping[selectedHouseType].defSurface;
		}
		hasDataSelected = true;
	}

	title: qsTr("Surface area")
	nextPage: 4

	Text {
		id: titleLabel

		anchors {
			baseline: parent.top
			baselineOffset: Math.round(70 * verticalScaling)
			left: bodyLabel.left
			//leftMargin: Math.round(123 * horizontalScaling)
		}

		text: qsTr("surface_area_title_text")

		color: colors.surfaceAreaTitle

		font {
			family: qfont.semiBold.name
			pixelSize: qfont.titleText
		}
	}

	Text {
		id: bodyLabel

		anchors {
			baseline: titleLabel.baseline
			baselineOffset: Math.round(33 * verticalScaling)
			//left: titleLabel.left
			horizontalCenter: surfaceAreaSpinner.horizontalCenter
		}

		text: qsTr("surface_area_body_text")

		color: colors.surfaceAreaBody

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}

	IconButton {
		id: iconImage

		anchors {
			bottom: titleLabel.bottom
			left: parent.right
			leftMargin: Math.round(-123 * horizontalScaling)
		}

		iconSource: "qrc:/images/info.svg"

		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("surface_area_info_popup_title"), qsTr("surface_area_info_popup_body"));
			var popup = qdialog.context;
			popup.bodyFontPixelSize = qfont.bodyText;
			popup.iconSource = "qrc:/images/info_popup.svg";
		}
	}

	NumberSpinner {
		id: surfaceAreaSpinner

		anchors {
			top: bodyLabel.baseline
			topMargin: Math.round(40 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}

		width: Math.round(180 * horizontalScaling)

		increment: 5
		valueSuffix: "m²"

		rangeMin: 5
		rangeMax: 730
		disableButtonAtMaximum: true
		disableButtonAtMinimum: true

		value: 0

		function valueToText(value) {
			return i18n.number(value, 0) + valueSuffix;
		}
	}

	Text {
		id: hintLabel

		anchors {
			baseline: surfaceAreaSpinner.bottom
			baselineOffset: Math.round(50 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}

		text: qsTr("surface_area_hint_text").arg(p.mapping[selectedHouseType].name).arg(p.mapping[selectedHouseType].defSurface)

		color: colors.surfaceAreaTip

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}
}
