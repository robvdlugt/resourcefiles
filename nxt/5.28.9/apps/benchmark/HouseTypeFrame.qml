import QtQuick 2.1
import qb.base 1.0
import BasicUIControls 1.0;

import qb.components 1.0

BenchmarkWizardFrame {
	id: houseTypeFrame

	title: qsTr("House type")
	nextPage: 2

	signal aptSelected(bool selected)

	function initWizardFrame(houseType) {
		// fill model with data when it's ready
		var length = app.houseTypeScreenData.length;
		for (var i = 0; i < length; ++i) {
			houseTypeModel.append(app.houseTypeScreenData[i]);
		}

		if (houseType !== undefined)
			houseTypeGroup.currentControlId = houseType;
	}

	function setCurrentControlId(value) {
		houseTypeGroup.currentControlId = value;
	}

	Text {
		id: titleLabel

		anchors {
			baseline: parent.top
			baselineOffset: 70
			left: parent.left
			leftMargin: Math.round(123 * horizontalScaling)
		}

		text: qsTr("house_type_title_text")

		color: colors.houseTypeSelectTitle

		font {
			family: qfont.semiBold.name
			pixelSize: qfont.titleText
		}
	}

	Text {
		id: bodyLabel

		anchors {
			baseline: titleLabel.baseline
			baselineOffset: 33
			left: titleLabel.left
		}

		text: qsTr("house_type_body_text")

		color: colors.houseTypeSelectBody

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}

	ControlGroup {
		id: houseTypeGroup
		exclusive: true

		onCurrentControlIdChanged: {
			if (currentControlId !== -1) {
				outcomeData = currentControlId;
				hasDataSelected = true;
				// if selected house type is apartment set next page to 1
				if (outcomeData === 0) {
					nextPage = 1;
					aptSelected(true);
				} else {
					nextPage = 2;
					aptSelected(false);
				}
			} else {
				hasDataSelected = false;
			}
		}
	}

	Grid {
		id: houseTypeGrid

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: bodyLabel.baseline
			topMargin: Math.round(40 * verticalScaling)
		}

		columns: 3

		Repeater {
			id: houseTypeRepeater

			model: houseTypeModel

			delegate: Item {
				id: buttonContainer

				height: Math.round(112 * horizontalScaling)
				width:  Math.round(129 * verticalScaling)

				TwoStateIconButton {
					id: selectableButton

					width: Math.round(88 * horizontalScaling)
					height: Math.round(64 * verticalScaling)

					anchors {
						top: parent.top
						horizontalCenter: parent.horizontalCenter
					}

					controlGroupId: index
					controlGroup: houseTypeGroup

					iconSourceUnselected: model.iconUnselected
					iconSourceSelected: model.iconSelected

					leftClickMargin: designElements.hMargin20
					rightClickMargin: designElements.hMargin20
					topClickMargin: designElements.vMargin20
					bottomClickMargin: Math.round(30 * verticalScaling)
				}

				Text {
					id: nameLabel
					anchors {
						baseline: selectableButton.bottom
						baselineOffset: Math.round(21 * verticalScaling)
						horizontalCenter: parent.horizontalCenter
					}
					width: parent.width
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					horizontalAlignment: Text.AlignHCenter
					color: selectableButton.textColor
					text: model.name
					wrapMode: Text.WordWrap
				}
			}
		}
	}

	ListModel {
		id: houseTypeModel
	}
}
