import QtQuick 2.1
import qb.components 1.0

SystrayIcon {
	visible: app.hasVacation
	objectName: "vacationSystrayIcon"
	image: "drawables/vacation-systray.svg"

	onClicked: {
		stage.openFullscreen(app.vacationOverviewScreenUrl);
	}
}
