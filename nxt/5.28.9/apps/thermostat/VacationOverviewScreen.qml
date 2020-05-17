
import QtQuick 2.1
import qb.components 1.0

/// Overview screen for vacation.

Screen {
	id: vacationOverviewScreen
	screenTitleIconUrl: "drawables/vacation.svg"
	screenTitle: qsTr("Vacation")

	QtObject {
		id: p

		function onVacationDataChanged() {
			var startTime = app.vacationData['startTime'];
			var from = app.formatDateTime(startTime, true);
			var to = app.formatDateTime(app.vacationData['endTime'], false);
			var temp = i18n.number(app.vacationData['temperature'], 1) + "°";
			txtVacationSettings.text = qsTr('From <font color="black"><b>%1</b></font> until <font color="black"><b>%2</b></font><br>Temperature not below <font color="black"><b>%3</b></font>')
				.arg(from).arg(to).arg(temp);

			txtVacationState.text = (new Date().getTime() >= startTime || startTime === 0) ? qsTr("Holiday active") : qsTr("Holiday planned");

			if (!app.hasVacation)
				vacationDataSavedText.visible = false;
		}

		function vacationDataSet() {
			vacationDataSavedText.visible = true;
		}
	}

	onShown: {
		app.vacationDataChanged.connect(p.onVacationDataChanged);
		app.vacationSet.connect(p.vacationDataSet);
		p.onVacationDataChanged();
	}

	onHidden: {
		vacationDataSavedText.visible = false;
		app.vacationDataChanged.disconnect(p.onVacationDataChanged);
	}

	Component.onDestruction: {
		app.vacationSet.disconnect(p.vacationDataSet);
	}

	Item {
		id: itemNoVacation
		visible: !app.hasVacation
		anchors.fill: parent

		Image {
			id: noVacationImg
			anchors {
				right: parent.right
				rightMargin: Math.round(40 * horizontalScaling)
				bottom: parent.bottom
				bottomMargin: - designElements.bottomBarHeight
			}
			source: "image://scaled/apps/thermostat/drawables/no-vacation-set.svg"
		}

		Text {
			id: txtNoVacation
			text: qsTr("Taking a break?<br>Use the holiday mode")
			color: colors.text
			width: Math.round(450 * horizontalScaling)
			wrapMode: Text.WordWrap
			anchors {
				left: parent.left
				leftMargin: Math.round(80 * horizontalScaling)
				baseline: parent.top
				baselineOffset: Math.round(60 * verticalScaling)
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.largeTitle
			}
		}

		Text {
			id: bodyText
			text: qsTr("vacation_mode_explain_body")
			color: colors.vacationBody
			width: Math.round(320 * horizontalScaling)
			wrapMode: Text.WordWrap
			anchors {
				left: txtNoVacation.left
				top: txtNoVacation.bottom
				topMargin: Math.round(40 * horizontalScaling)
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		StandardButton {
			id: butSetVacation
			text: qsTr("I'm going away")
			primary: true
			anchors {
				left: txtNoVacation.left
				top: bodyText.bottom
				topMargin: Math.round(40 * horizontalScaling)
			}
			onClicked: {
				stage.openFullscreen(app.vacationSetScreenUrl, {newVacation: true});
			}
		}
	}

	Item {
		id: vacationSet
		visible: app.hasVacation
		anchors.fill: parent

		Image {
			id: vacationImg
			anchors {
				right: parent.right
				rightMargin: Math.round(40 * horizontalScaling)
				bottom: parent.bottom
				bottomMargin: - designElements.bottomBarHeight
			}
			source: "image://scaled/apps/thermostat/drawables/vacation-set.svg"
		}

		Text {
			id: vacationTxt
			text: qsTr("Enjoy your holidays")
			color: colors.text
			width: Math.round(320 * horizontalScaling)
			wrapMode: Text.WordWrap
			anchors {
				left: parent.left
				leftMargin: Math.round(80 * horizontalScaling)
				baseline: parent.top
				baselineOffset: Math.round(60 * verticalScaling)
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.largeTitle
			}
		}

		Image {
			id: vacationStateIcon
			sourceSize.width: Math.round(24 * horizontalScaling)
			anchors {
				left: vacationTxt.left
				leftMargin: designElements.hMargin5
				top: vacationTxt.bottom
				topMargin: Math.round(35 * verticalScaling)
			}
			source: "image://scaled/apps/boilerMonitor/drawables/badge-ok.svg"
		}

		Text {
			id: txtVacationState
			width: Math.round(320 * horizontalScaling)
			wrapMode: Text.WordWrap
			color: colors._pocahontas
			anchors {
				left: vacationStateIcon.right
				leftMargin: designElements.hMargin5
				verticalCenter: vacationStateIcon.verticalCenter
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		Text {
			id: txtVacationSettings
			width: Math.round(320 * horizontalScaling)
			wrapMode: Text.WordWrap
			color: colors.titleText
			anchors {
				left: vacationTxt.left
				top: vacationStateIcon.bottom
				topMargin: Math.round(35 * verticalScaling)
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		StandardButton {
			id: butEdit
			text: qsTr("Edit")
			anchors {
				left: vacationTxt.left
				top: txtVacationSettings.bottom
				topMargin: Math.round(30 * verticalScaling)
			}
			onClicked: stage.openFullscreen(app.vacationSetScreenUrl, {editVacation: true});
		}

		StandardButton {
			id: butDelete
			text: qsTr("Delete")
			anchors {
				left: butEdit.right
				leftMargin: Math.round(10 * horizontalScaling)
				bottom: butEdit.bottom
			}
			onClicked: app.abortVacation()
		}
	}

	WarningBox {
		id: vacationDataSavedText
		width: Math.round(455 * horizontalScaling)
		height: Math.round(45 * verticalScaling)
		warningText: qsTr("Your vacation is set and saved.")
		warningIcon: "image://scaled/apps/thermostat/drawables/vacation.svg"
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: vacationSet.bottom
			topMargin: Math.round(72 * verticalScaling)
		}
		visible: false
	}
}
