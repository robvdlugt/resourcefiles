import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0

Rectangle {
	id: root

	function populate(friends) {
		for (var i = 0; i < friends.length; i++) {
			friendDataModel.append(friends[i]);
		}
	}

	anchors.fill: parent

	Column {
		id: column

		spacing: Math.round(20 * verticalScaling)
		width: parent.width

		anchors {
			top: parent.top
			topMargin: Math.round(30 * verticalScaling)
			left: parent.left
		}

		Repeater {
			model: friendDataModel

			delegate: Item {
				id: tapDetailsItem

				height: Math.round(35 * verticalScaling)
				width: column.width

				BenchmarkSmallBalloon {
					id: balloon
					anchors {
						verticalCenter: parent.verticalCenter
						left: parent.left
						leftMargin: Math.round(40 * horizontalScaling)
					}
					imageSource: "drawables/notificationBlack.svg"
					colorize: true
					colorizeColor: colors.percentileColors[model.percentile]
				}

				Text {
					id: name

					elide: Text.ElideRight
					text: model.name

					anchors {
						left: balloon.right
						leftMargin: designElements.hMargin10
						right: familyImageItem.left
						verticalCenter: parent.verticalCenter
					}

					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
				}

				Item {
					id: familyImageItem

					width: Math.round(80 * horizontalScaling)
					height: familyImage.height

					anchors {
						right: houseImageItem.left
						rightMargin: designElements.hMargin10
						verticalCenter: parent.verticalCenter
					}

					Image {
						id: familyImage
						source: model.familyImage ? "image://scaled/" + qtUtils.urlPath(Qt.resolvedUrl(model.familyImage)) : ""
						anchors.horizontalCenter: parent.horizontalCenter
					}
				}

				Item {
					id: houseImageItem

					anchors {
						right: houseSize.left
						rightMargin: designElements.hMargin10
						verticalCenter: parent.verticalCenter
					}

					width: Math.round(80 * horizontalScaling)
					height: houseImage.height

					Image {
						id: houseImage
						source: model.homeImage ? "image://scaled/" + qtUtils.urlPath(Qt.resolvedUrl(model.homeImage)) : ""
						anchors.horizontalCenter: parent.horizontalCenter
					}
				}

				Text {
					id: houseSize

					width: Math.round(75 * horizontalScaling)

					anchors {
						right: buildPeriodText.left
						verticalCenter: parent.verticalCenter
					}

					text: model.homeSize + " m²"
					font {
						family: qfont.light.name
						pixelSize: qfont.bodyText
					}
				}

				Text {
					id: buildPeriodText

					width: Math.round(130 * horizontalScaling)

					anchors {
						right: parent.right
						verticalCenter: parent.verticalCenter
					}

					text: model.buildPeriodText
					font {
						family: qfont.light.name
						pixelSize: qfont.bodyText
					}
				}
			}
		}
	}

	ListModel {
		id: friendDataModel
	}
}
