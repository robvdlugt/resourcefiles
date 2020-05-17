import QtQuick 2.1
import qb.base 1.0
import BasicUIControls 1.0;

import qb.components 1.0

BenchmarkWizardFrame {
	id: aptOptionsFrame

	title: qsTr("House type")
	nextPage: 2

	function initWizardFrame(options) {
		if (options !== undefined) {
			if (options) {
				aptOptRoofCheckbox.selected = options & 1;
				aptOptCornerCheckbox.selected = options & 2;
				aptOptGroundCheckbox.selected = options & 4;
			} else {
				aptOptNoaCheckbox.selected = true;
			}
		}
	}

	Text {
		id: titleLabel

		anchors {
			baseline: parent.top
			baselineOffset: Math.round(70 * verticalScaling)
			left: aptOptionsColumn.left
		}

		text: qsTr("apt_options_title_text")

		color: colors.aptOptionsTitle

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
			left: titleLabel.left
		}

		text: qsTr("apt_options_body_text")

		color: colors.aptOptionsBody

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}

	function calculateValue() {
		outcomeData = aptOptRoofCheckbox.selected
					| aptOptCornerCheckbox.selected << 1
					| aptOptGroundCheckbox.selected << 2;
	}

	ControlGroup {
		id: aptOptionsGroup
		exclusive: false
		onSelectedChanged: {
			if (selected) {
				hasDataSelected = true;
			} else {
				hasDataSelected = false;
			}
		}
	}

	Column {
		id: aptOptionsColumn

		width: Math.round(445 * horizontalScaling)
		anchors.top: bodyLabel.baseline
		anchors.topMargin: Math.round(40 * verticalScaling)
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: designElements.spacing8

		StandardCheckBox {
			id: aptOptRoofCheckbox
			width: parent.width
			controlGroup: aptOptionsGroup
			text: qsTr("apt_opt_roof")
			onSelectedChanged: {
				if (selected) {
					aptOptNoaCheckbox.selected = false;
					aptOptGroundCheckbox.selected = false;
				}
				calculateValue();
			}
		}
		StandardCheckBox {
			id: aptOptGroundCheckbox
			width: parent.width
			controlGroup: aptOptionsGroup
			text: qsTr("apt_opt_ground")
			onSelectedChanged: {
				if (selected) {
					aptOptNoaCheckbox.selected = false;
					aptOptRoofCheckbox.selected = false;
				}
				calculateValue();
			}
		}
		StandardCheckBox {
			id: aptOptCornerCheckbox
			width: parent.width
			controlGroup: aptOptionsGroup
			text: qsTr("apt_opt_corner")
			onSelectedChanged: {
				if (selected) {
					aptOptNoaCheckbox.selected = false;
				}
				calculateValue();
			}
		}
		StandardCheckBox {
			id: aptOptNoaCheckbox
			width: parent.width
			controlGroup: aptOptionsGroup
			text: qsTr("apt_opt_noa")
			onSelectedChanged: {
				if (selected) {
					aptOptRoofCheckbox.selected = false;
					aptOptGroundCheckbox.selected = false;
					aptOptCornerCheckbox.selected = false;
				}
				calculateValue();
			}
		}
	}
}
