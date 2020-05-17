import QtQuick 2.1
import qb.base 1.0
import BasicUIControls 1.0;

import qb.components 1.0

BenchmarkWizardFrame {
	id: familySizeFrame

	title: qsTr("Family size")
	nextPage: 5

	function initWizardFrame(size) {
		// fill model with data when it's ready
		var length = app.familyTypeScreenData.length
		for (var i = 0; i < length; ++i) {
			familySizeModel.append(app.familyTypeScreenData[i]);
		}

		if (size !== undefined)
			familySizeGroup.currentControlId = size - 1;
	}

	function setCurrentControlId(value) {
		familySizeGroup.currentControlId = value - 1;
	}

	function getFamilySizeIcon() {
		return familySizeModel.get(familySizeGroup.currentControlId).iconUnselected;
	}

	function getFamilySizeLabel() {
		return familySizeModel.get(familySizeGroup.currentControlId).name;
	}

	Text {
		id: titleLabel

		anchors {
			baseline: parent.top
			baselineOffset: Math.round(70 * verticalScaling)
			left: familySizeGrid.left
			leftMargin: Math.round(20 * horizontalScaling)
		}

		text: qsTr("family_size_title_text")

		color: colors.familySizeSelectTitle

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

		text: qsTr("family_size_body_text")

		color: colors.familySizeSelectBody

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}

	ControlGroup {
		id: familySizeGroup
		exclusive: true

		onCurrentControlIdChanged: {
			if (currentControlId !== -1) {
				outcomeData = currentControlId+1;  // 0 in bxt dataset is reserved as unknown family type
				hasDataSelected = true;
			} else {
				hasDataSelected = false;
			}
		}
	}

	Grid {
		id: familySizeGrid

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: bodyLabel.baseline
			topMargin: Math.round(40 * verticalScaling)
		}

		columns: 3

		Repeater {
			id: familySizeRepeater

			model: familySizeModel

			delegate: Item {
				id: buttonContainer

				height: Math.round(112 * verticalScaling)
				width:  Math.round(129 * horizontalScaling)

				TwoStateIconButton {
					id: selectableButton

					width:  Math.round(88 * horizontalScaling)
					height: Math.round(64 * verticalScaling)

					anchors {
						top: parent.top
						horizontalCenter: parent.horizontalCenter
					}

					controlGroupId: index
					controlGroup: familySizeGroup

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
		id: familySizeModel
	}
}
