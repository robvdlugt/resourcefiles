import QtQuick 2.1
import qb.components 1.0

/**
 *	@brief	CategoryListItem is used to select the different frames from a vertical menu
 *			See an example usage in the settings app. Every CategoryListItem opens a different
 *			frame in the settings screen.
 */

Item {
	id: itemCategoryListItem
	width: Math.round(198 * horizontalScaling)
	height: Math.round(53 * verticalScaling)
	anchors.leftMargin: Math.round(18 * horizontalScaling)

	property string kpiPostfix: name
	property bool selected: false

	/// Item in list was clicked.
	signal clicked()

	Component.onCompleted: {
		maItem.clicked.connect(clicked);
	}

	Rectangle {
		id: itemRectangle
		objectName: {
			var a = kpiPrefix.split("/");
			a[a.length - 1].split(".")[0];
		}

		width: parent.width
		height: parent.height
		color: colors.ibListViewBckgNohighlight

		MouseArea {
			id: maItem
			anchors.fill: parent
		}

		Text {
			id: nameCategory
			width: parent.width
			text:  name
			color: colors.systemMenuUp
			verticalAlignment: Text.AlignBottom
			anchors {
				left: parent.left
				leftMargin: Math.round(30 * horizontalScaling)
				verticalCenter: parent.verticalCenter
			}
			font {
				pixelSize: qfont.titleText
				family: qfont.regular.name
			}
		}
	}

	Rectangle {
		id: separator
		height: 2
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			rightMargin: Math.round(18 * horizontalScaling)
		}
		color: colors.categoryListItemSeparator
		visible: index > 0
	}

	states: [
		State {
			name: "selected"
			when: selected
			PropertyChanges { target: itemRectangle; color: colors.ibListViewBckgHighlight }
			PropertyChanges { target: nameCategory; font.family: qfont.semiBold.name; color: colors.systemMenuSelected }
		}
	]
}
