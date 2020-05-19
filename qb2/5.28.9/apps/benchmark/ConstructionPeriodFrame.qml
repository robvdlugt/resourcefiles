import QtQuick 2.1
import BasicUIControls 1.0;

import qb.components 1.0
import qb.base 1.0

BenchmarkWizardFrame {
	id: constructionPeriodFrame

	function initWizardFrame(period) {
		// fill model with data when it's ready
		var length = app.constructionPeriodScreenData.length;
		for (var i = 0; i < length; ++i) {
			constructionPeriodModel.append({ text: app.constructionPeriodScreenData[i] });
		}

		if (period)
			radioButtonGroup.currentControlId = period;
	}

	function getBuildPeriodText() {
		return constructionPeriodModel.get(radioButtonGroup.currentControlId).text;
	}

	function setCurrentControlId(value) {
		radioButtonGroup.currentControlId = value;
	}

	title: qsTr("Construction period")
	nextPage: 3

	Text {
		id: title

		anchors {
			baseline: parent.top
			baselineOffset: 70
			left: radioButtonList.left
		}

		font {
			pixelSize: qfont.titleText
			family: qfont.semiBold.name
		}

		text: qsTr("construction_period_title")

		color: colors.consPerTitle
	}

	Text {
		id: body

		anchors {
			baseline: title.bottom
			baselineOffset: 33
			left: title.left

		}

		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}

		text: qsTr("construction_period_body")

		color: colors.consPerBody
	}

	ControlGroup {
		id: radioButtonGroup
		exclusive: true

		onCurrentControlIdChanged: {
			if (currentControlId !== -1) {
				outcomeData = currentControlId;
				hasDataSelected = true;
			} else {
				hasDataSelected = false;
			}
		}
	}

	Grid {
		id: radioButtonList

		columns: 2
		spacing: Math.round(6 * horizontalScaling)
		flow: Grid.TopToBottom

		anchors {
			baseline: body.baseline
			baselineOffset: 40
			//left: parent.left
			//leftMargin: Math.round(188 * horizontalScaling)
			horizontalCenter: parent.horizontalCenter
		}

		Repeater {
			id: constructionPeriods

			model: constructionPeriodModel
			delegate: radioButtonDelegate
		}
	}

	Component {
		id: radioButtonDelegate

		// spacing between grid columns is realized by additional Item in delegate
		Item {
			width: Math.round(202 * horizontalScaling)
			height: Math.round(35 * verticalScaling)

			StandardRadioButton {
				property string kpiPostfix: text
				width: Math.round(190 * verticalScaling)
				controlGroupId: index
				controlGroup: radioButtonGroup
				bottomClickMargin: Math.round(2 * horizontalScaling)
				topClickMargin: Math.round(2 * verticalScaling)
				text: model.text
			}
		}
	}

	ListModel {
		id: constructionPeriodModel
	}
}
