import QtQuick 2.1
import BasicUIControls 1.0

import qb.base 1.0
import qb.components 1.0

DateSelectorComponent {
	id: dateSelector
	property int implicitWidth:  Math.round(228 * horizontalScaling)
	property int implicitWidthWeekMode:  Math.round(260 * horizontalScaling)
	width: mode === DateSelectorComponent.MODE_WEEK ? implicitWidthWeekMode : implicitWidth
	height: butPrev.height

	QtObject {
		id: p
		property bool prevNextBtnState: true
		property bool prevPrevBtnState: true
	}

	Component.onCompleted: {
		setShortMonthNames(i18n.monthsShort);
		setLongMonthNames(i18n.monthsFull);
	}

	onPeriodChanged: {
		periodTxt.text = period;
	}

	onPeriodMinimumReached: {
		p.prevPrevBtnState = butPrev.enabled = !reached;
	}

	onPeriodMaximumReached: {
		p.prevNextBtnState = butNext.enabled = !reached;
	}

	IconButton {
		id: butPrev
		width: height
		height: Math.round(45 * verticalScaling)
		anchors.left: parent.left
		iconSource: "qrc:/images/arrow-left.svg"
		radius: 0

		overlayWhenUp:        false
		colorUp:              "transparent"
		colorDown:            colors.dateSelectorBtnDown
		colorDisabled:        "transparent"
		overlayColorDown:     colors.dsOverlayColorDown
		overlayColorDisabled: colors.dsOverlayColorDisabled
		property string kpiPostfix: "dateSelectorPrev"

		onClicked: previousPeriod()
	}

	IconButton {
		id: butNext
		width: height
		height: butPrev.height
		anchors.right: parent.right
		iconSource: "qrc:/images/arrow-right.svg"
		radius: 0

		overlayWhenUp:        false
		colorUp:              "transparent"
		colorDown:            butPrev.colorDown
		colorDisabled:        "transparent"
		overlayColorDown:     butPrev.overlayColorDown
		overlayColorDisabled: colors.dsOverlayColorDisabled
		property string kpiPostfix: "dateSelectorNext"

		onClicked: nextPeriod()
	}

	Text {
		id: periodTxt
		height: parent.height
		anchors {
			left: butPrev.right
			right: butNext.left
		}
		verticalAlignment: Text.AlignVCenter
		horizontalAlignment: Text.AlignHCenter
		color: colors.dateSelectorText
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}

	onEnabledChanged: {
		if (enabled === false) {
			butNext.enabled = false;
			butPrev.enabled = false;
			periodTxt.color = colors.dateSelectorDisabledText;
		} else {
			butNext.enabled = p.prevNextBtnState;
			butPrev.enabled = p.prevPrevBtnState;
			periodTxt.color = colors.dateSelectorText;
		}
	}
}
