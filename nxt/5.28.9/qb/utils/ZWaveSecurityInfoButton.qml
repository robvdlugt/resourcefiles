import QtQuick 2.1

import qb.components 1.0

IconButton {
	id: infoSecurityButton
	property string deviceUuid

	iconSource: "qrc:/images/info.svg"
	primary: true
	topClickMargin: 3
	bottomClickMargin: topClickMargin
	visible: zWaveUtils.devices[deviceUuid] && zWaveUtils.devices[deviceUuid].securityInfo
			 ? zWaveUtils.devices[deviceUuid].securityInfo.isMaxSecurityLevel === "false"
			 : false

	onClicked: zWaveUtils.showInsecureInclusionPopup(deviceUuid)
}
