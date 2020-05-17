import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

import DateTracker 1.0

Widget {
	id: logo
	width: tenantlogo.width + Math.round(30 * horizontalScaling)
	height: parent.height

	Image {
		id: tenantlogo
		anchors.centerIn: parent
		source: "image://scaled/images/" + fileName + (dimState ? "_dim" : "") + ".svg"
		property string fileName: "logo"
	}

	states: [
		State {
			name: "xmas"
			when: DateTracker.month === 12 && (DateTracker.day >= 24 && DateTracker.day <= 26)
			PropertyChanges { target: tenantlogo; fileName: "logo-xmas" }
		},
		State {
			name: "valentine"
			when: DateTracker.day === 14 && DateTracker.month === 2
			PropertyChanges { target: tenantlogo; fileName: "logo-valentine" }
		},
		State {
			name: "easter"
			when: DateTracker.isEaster
			PropertyChanges { target: tenantlogo; fileName: "logo-easter" }
		}
	]
}
