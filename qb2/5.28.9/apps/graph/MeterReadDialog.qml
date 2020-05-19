import QtQuick 2.1

Item {
	id: root

	function populate(meters) {
		metersModel.clear();
		if(!meters.length) return;
		for (var i = 0; i < meters.length; i++) {
			metersModel.append(meters[i]);
		}
	}

	ListModel {
		id: metersModel
	}
	Component {
		id: meterComponent
		Item {

			width: childrenRect.width
			height: Math.round(40 * verticalScaling)

			Meter {
				id: meter
				value: metersModel.get(index).value
				anchors {
					left: title.right
					leftMargin: Math.round(30 * horizontalScaling)
					verticalCenter: parent.verticalCenter
				}
			}
			Text {
				id: unit
				text: metersModel.get(index).unit
				width: Math.round(30 * horizontalScaling)
				anchors {
					left: meter.right
					leftMargin: designElements.hMargin10
					verticalCenter: meter.verticalCenter
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
			}
			Text {
				id: title
				text: metersModel.get(index).title
				anchors {
					verticalCenter: meter.verticalCenter
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
			}
		}
	}

	Column {
		spacing: designElements.spacing10
		anchors {
			verticalCenter: parent.verticalCenter
			horizontalCenter: parent.horizontalCenter
		}
		Repeater {
			model: metersModel
			delegate: meterComponent
			onItemAdded: {
				// set this here because of parent being undefined before this
				item.anchors.right = parent.right;
			}
		}
	}
}
