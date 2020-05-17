import QtQuick 2.1
import qb.components 1.0

Item {
	id: root
	anchors.fill: parent

	Image {
		id: imgProduction
		source: "image://scaled/apps/graph/drawables/production-graph.svg"
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: designElements.vMargin5
		}
	}

	Text {
		id: txtProduction
		text: qsTr("Toon divides your estimated annual yield over the month an the basis of the number of hours of sunshine in an average year.")
		anchors {
			left: imgProduction.left
			right: imgProduction.right
			bottom: parent.bottom
			bottomMargin: designElements.vMargin10
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		wrapMode: Text.WordWrap
	}
}
