import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Popup {
	id: throbberPopup

	Rectangle {
		id: maskedArea

		anchors.fill: parent
		color: colors.fstMaskedArea
		opacity: designElements.opacity
	}

	Throbber {
		id: loadingThrobber

		width: Math.round(90 * horizontalScaling)
		height: Math.round(87 * horizontalScaling)

		anchors {
			centerIn: parent
		}

		Component.onCompleted: {
			smallDotColor = colors.fstDot;
			mediumDotColor = colors.fstDot;
			bigDotColor = colors.fstDot;
			largeDotColor = colors.fstDot;
		}
	}

	MouseArea {
		id: nonClickableArea

		anchors.fill: parent
	}

}
