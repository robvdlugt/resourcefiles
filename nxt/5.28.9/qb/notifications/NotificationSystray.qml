import QtQuick 2.1
import qb.components 1.0

SystrayIcon {
	objectName: "notificationsSystrayIcon"
	posIndex: 1000
	visible: notifications.count > 0 && isNormalMode
	image: "drawables/notifications-icon.svg"

	onClicked: {
		notifications.show(true);
	}
}
