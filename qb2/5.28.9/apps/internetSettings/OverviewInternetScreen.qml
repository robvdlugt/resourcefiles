import QtQuick 2.1
import qb.components 1.0

Screen {
	id: overviewInternetScreen
	screenTitle: qsTr("Connectivity")

	QtObject {
		id: p
		property url advicePopupUrl: "qrc:/qb/components/AdvicePopup.qml"
		property variant errorsModel: []
	}

	function showAdvice(adviceText, errorCode) {
		qdialog.showDialog(qdialog.SizeLarge, qsTr("Solve the problem"), p.advicePopupUrl);
		qdialog.context.dynamicContent.content = adviceText;
		qdialog.context.dynamicContent.errorCode = errorCode;
	}

	function changeInetState() {
		var statusText, statusIcon, adviceText, errorCode;
		if (app.smStatus < app._ST_CONFIGURED) {
			statusText = qsTr("overview_internet_title_no_conn_router");
			statusIcon = "image://scaled/apps/internetSettings/drawables/status-error-internet.svg"
			adviceText =  qsTr("overview_internet_advice_no_conn_router");
			errorCode = "D01";
		} else if (app.smStatus < app._ST_INTERNET) {
			statusText = qsTr("overview_internet_title_no_conn_internet");
			statusIcon = "image://scaled/apps/internetSettings/drawables/status-error-internet.svg"
			adviceText =  qsTr("overview_internet_advice_no_conn_internet");
			errorCode = "D02";
		} else if (!app.upstreamConnectedState) {
			statusText = qsTr("overview_internet_title_no_conn_sc");
			statusIcon = "image://scaled/apps/internetSettings/drawables/status-error-cloud.svg"
			adviceText =  qsTr("overview_internet_advice_no_conn_sc");
			errorCode = "D03";
		}

		if (statusText) {
			p.errorsModel = [{
				'deviceLabel': qsTr("Toon"),
				'deviceIcon': "image://scaled/images/display.svg",
				'statusText': statusText,
				'statusIcon': statusIcon,
				'adviceText': adviceText,
				'errorCode': errorCode
			}]
		} else {
			p.errorsModel = [];
		}
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		app.smStatusChanged.connect(changeInetState);
		app.upstreamConnectedStateChanged.connect(changeInetState);
		changeInetState();
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
		app.smStatusChanged.disconnect(changeInetState);
		app.upstreamConnectedStateChanged.disconnect(changeInetState);
	}

	ErrorCardsView {
		id: cardView
		anchors.fill: parent
		emptyViewText: qsTr("There are no connectivity issues anymore.")
		model: p.errorsModel
		delegate: ErrorCard {
			label: modelData.deviceLabel
			icon: Qt.resolvedUrl(modelData.deviceIcon)
			statusIcon: Qt.resolvedUrl(modelData.statusIcon)
			statusText: modelData.statusText
			errorCode: modelData.errorCode ? modelData.errorCode : ""

			onButtonClicked: showAdvice(modelData.adviceText, modelData.errorCode)
		}
	}
}
