import QtQuick 2.1
import qb.components 1.0

Item {
	id: popup
	anchors.fill: parent
	property ThermostatApp app

	// Toggle
	OnOffToggle {
		id: timeDateToggle

		anchors {
			left: parent.left
			leftMargin: designElements.hMargin20
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: -designElements.vMargin20
		}

		sliderWidth: Math.round(75 * horizontalScaling)
		sliderHeight: Math.round(40 * verticalScaling)
		knobWidth: Math.round(34 * horizontalScaling)

		onClicked: popup.state = (selected) ? "time" : "date"

		backgroundColorLeft: colors._bg
		shadowColorLeft: colors._bg
		backgroundColorRight: backgroundColorLeft
		shadowColorRight: shadowColorLeft
	}

	Image {
		id: toggleTimeIcon
		sourceSize.width: Math.round(20 * horizontalScaling)

		anchors {
			horizontalCenter: timeDateToggle.left
			horizontalCenterOffset: timeDateToggle.radius
			verticalCenter: timeDateToggle.verticalCenter
		}
	}

	Image {
		id: toggleDateIcon
		sourceSize.width: Math.round(20 * horizontalScaling)

		anchors {
			horizontalCenter: timeDateToggle.right
			horizontalCenterOffset: -timeDateToggle.radius + 1
			verticalCenter: timeDateToggle.verticalCenter
		}
	}

	// Slider
	MouseArea {
		id: slider
		onClicked: handleSlider(mouseX)
		onPositionChanged: handleSlider(mouseX)

		anchors {
			verticalCenter: timeDateToggle.verticalCenter
			left: timeDateToggle.right
			right: parent.right
			leftMargin: timeDateToggle.anchors.leftMargin
			rightMargin: timeDateToggle.anchors.leftMargin
		}
		height: handle.height + designElements.vMargin10

		QtObject {
			id: sliderData
			property variant labels: []
			property int value: 0
		}

		Rectangle {
			id: groove
			anchors.centerIn: parent
			width: parent.width - handle.width
			height: Math.round(4 * verticalScaling)
			color: colors._bg
			radius: 8
		}

		Repeater {
			id: ticks
			model: sliderData.labels.length

			Item {
				anchors.fill: parent

				Rectangle {
					width: Math.round(10 * horizontalScaling)
					height: Math.round(10 * verticalScaling)
					radius: width / 2
					color: colors._bg
					anchors.verticalCenter: parent.verticalCenter
					x: slider.getTickPosition(index) - width / 2
				}

				Text {
					text: getTickText()
					color: sliderData.value === index ? colors.black : colors._gandalf
					anchors.baseline: parent.top
					x: slider.getTickPosition(index) - getTickTextOffset(width)

					font {
						pixelSize: qfont.metaText
						family: sliderData.value === index ? qfont.bold.name : qfont.regular.name
					}
				}

				function getTickText() {
					if (popup.state === "time") return qsTr("%n hour(s)", "", sliderData.labels[index] || index);
					if (popup.state === "date") return qsTr("%n day(s)", "", sliderData.labels[index] || index);
					return "";
				}

				function getTickTextOffset(width) {
					if (index === 0) return designElements.hMargin5;
					if (index === sliderData.labels.length - 1) return width - designElements.hMargin5;
					return width / 2;
				}
			}
		}

		Rectangle {
			id: handle

			anchors.verticalCenter: parent.verticalCenter
			x: slider.getTickPosition(sliderData.value) - width / 2

			color: slider.pressed ? colors._pressed : colors.white
			border.color: colors._branding
			border.width: 4
			width: Math.round(30 * horizontalScaling)
			height: Math.round(30 * verticalScaling)
			radius: width / 2
		}

		function getTickPosition(i) {
			return (handle.width / 2) + (i * groove.width / (sliderData.labels.length - 1));
		}

		function handleSlider(pos) {
			var n = Math.round((sliderData.labels.length - 1) * pos / width);
			sliderData.value = Math.max(0, Math.min(n, sliderData.labels.length - 1));
		}
	}

	// End time/date text + confirm button
	Text {
		text: qsTr("On <b>%1°</b> until <b>%2</b>")
			.arg(i18n.number(app.thermInfo.realSetpoint / 100.0, 1))
			.arg(formatEndDate(getEndDate()))

		anchors {
			right: confirmButton.left
			rightMargin: designElements.hMargin20
			verticalCenter: confirmButton.verticalCenter
		}
		font {
			pixelSize: qfont.titleText
			family: qfont.regular.name
		}
		horizontalAlignment: Text.AlignHCenter
		wrapMode: Text.WordWrap
	}

	StandardButton {
		id: confirmButton
		primary: true
		text: qsTr("Confirm")

		anchors {
			right: parent.right
			rightMargin: designElements.hMargin20
			bottom: parent.bottom
			bottomMargin: designElements.vMargin20
		}

		onClicked: {
			qdialog.reset();
			app.setVacationUntil(getEndDate(), app.thermInfo.realSetpoint)
		}
	}

	function formatEndDate(date) {
		if (state === "time")
			return i18n.dateTime(date, i18n.time_yes | i18n.secs_no | i18n.date_no);
		return i18n.dateTime(date, i18n.time_yes | i18n.secs_no | i18n.date_yes | i18n.year_no | i18n.mon_short);
	}

	function getEndDate() {
		if (state === "time") return dateAfterHours(sliderData.labels[sliderData.value] || 0);
		if (state === "date") return dateAfterDays(sliderData.labels[sliderData.value] || 0);
		return new Date();
	}

	function dateAfterHours(hours) {
		var future = new Date();
		future.setHours(future.getHours() + hours);
		return future;
	}

	function dateAfterDays(days) {
		var future = new Date();
		future.setDate(future.getDate() + days);
		return future;
	}

	state: "time"
	states: [
		State {
			name: "time"
			PropertyChanges { target: toggleTimeIcon; source: "drawables/clock-active.svg" }
			PropertyChanges { target: toggleDateIcon; source: "drawables/calendar-inactive.svg" }
			PropertyChanges { target: sliderData; value: 1 }
			PropertyChanges { target: sliderData; labels: [1, 2, 4, 8, 12] }
		},
		State {
			name: "date"
			PropertyChanges { target: toggleTimeIcon; source: "drawables/clock-inactive.svg" }
			PropertyChanges { target: toggleDateIcon; source: "drawables/calendar-active.svg" }
			PropertyChanges { target: sliderData; value: 1 }
			PropertyChanges { target: sliderData; labels: [1, 2, 4, 7, 14, 30] }
		}
	]
}
