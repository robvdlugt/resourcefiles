import QtQuick 2.11
import QtQuick.VirtualKeyboard 2.3

import qb.components 1.0
import qb.base 1.0

import "Constants.js" as Constants

Widget {
	id: eMeterFrame
	clip: true

	property EMetersSettingsApp app

	onHidden: {
		qtUtils.clearFocus();
		p.inputItemOffset = 0;
	}

	QtObject {
		id: p
		property int inputItemOffset: 0
		property bool solarFeature: globals.productOptions["solar"] && globals.productOptions["solar"] === "1"

		// When should we show the solar install button? Well.....
		//- Solar app enabled in Feature.json
		//- P1 driver reports gridMeteringConfiguration allows import and export
		//- analogSolar is not already installed on an energy meter

		property bool showSolarInstall:
			   feature.appSolarEnabled()
			&& scsyncCanActivateSolar
			&& (typeof app.connectedInfo['gridMeteringConfiguration'] !== 'undefined' && app.connectedInfo['gridMeteringConfiguration'] === 2)
			&& (hasSolarMetering === false)

		property bool scsyncCanActivateSolar: false
		property bool hasSolarMetering: false
		property bool hasWaterMetering: false

		function logSolarInstallConditions() {
			console.log("showSolarInstall:", showSolarInstall)
			console.log("feature.appSolarEnabled()", feature.appSolarEnabled())
			console.log("scsyncCanActivateSolar", scsyncCanActivateSolar)
			console.log("app.connectedInfo['gridMeteringConfiguration'] === 2", app.connectedInfo['gridMeteringConfiguration'] === 2)
			console.log("app.connectedInfo['gridMeteringConfiguration']", app.connectedInfo['gridMeteringConfiguration'])
			console.log("(hasSolarMetering === false)", (hasSolarMetering === false))
		}

		function sensorConfigUpdateHandler() {
			var tmpSolarMetering = false, tmpWaterMetering = false;
			for (var idx = 0; idx < app.maConfiguration.length; idx++) {
				if (app.maConfiguration[idx].statusInt & Constants.CONFIG_STATUS.SOLAR)
					tmpSolarMetering = true;
				if (app.maConfiguration[idx].statusInt & Constants.CONFIG_STATUS.WATER)
					tmpWaterMetering = true;
			}
			hasSolarMetering = tmpSolarMetering;
			hasWaterMetering = tmpWaterMetering;
		}

		function waterTariffSave(text) {
			var tariff = text.replace(i18n.decimalSeparator(),".");
			app.setWaterTariff(tariff);
		}

		function waterTariffValidate(text, isFinal) {
			if (isFinal) {
				// replace locale decimal separator by dot in order to parse as float
				var asFloat = parseFloat(text.replace(i18n.decimalSeparator(),"."));
				if (isNaN(asFloat) || asFloat <= 0)
					return {content: qsTr("Please enter a value larger than %1").arg(0)};
				else if (asFloat >= 100)
					return {content: qsTr("Please enter a value smaller than %1").arg(100)};
			}
			return null;
		}

		function ensureInputVisibility() {
			p.inputItemOffset = 0;
			if (InputContext.inputItem !== null && !qtUtils.isRootItem(InputContext.inputItem)) {
				var keyboardRectY = labelContainer.mapFromItem(home, 0, Qt.inputMethod.keyboardRectangle.y - Qt.inputMethod.keyboardRectangle.height).y;
				var inputItemY = labelContainer.mapFromItem(InputContext.inputItem, 0, InputContext.inputItem.y).y;
				if (inputItemY - keyboardRectY > 0) {
					p.inputItemOffset = - (inputItemY - keyboardRectY) - InputContext.inputItem.height - designElements.vMargin20;
				}
			}
		}
	}

	function updateStatus() {
		var repeaters = app.repeaterDevices;
		var adapters = app.maDevices;
		var counter = 0;

		if (repeaters.length > 0) {
			counter = 0
			for (var i = 0; i < repeaters.length; i++) {
				if (repeaters[i].IsConnected == 0) {
					counter++;
				}
			}
			repeaterLabel.rightText = counter ? qsTr("%1 not connected").arg(counter) : qsTr("%1 connected").arg(repeaters.length);
		}
		else {
			repeaterLabel.rightText = qsTr("Not installed");
		}

		meteradapterLabel.rightText = app.commonStatusString;
	}

	function updateAnalogSection() {
		var elecUsage = app.getUsageByType("elec");
		var elecUsageDevice = elecUsage ? app.usageDevicesInfo[elecUsage.deviceIndex] : undefined;
		if (elecUsageDevice &&
				elecUsageDevice.deviceStatus === Constants.USAGEDEVICE_STATUS.CONN_OK &&
				(elecUsage.usage.measureType === Constants.MEASURE_TYPE.ANALOG ||
				 elecUsage.usage.measureType === Constants.MEASURE_TYPE.LASER)) {

			var elecDualRate = (app.elecRate === Constants.RATE_TYPE.DUAL);
			if (elecDualRate) {
				var lowRateStartHour    = parseInt(app.connectedInfo.lowRateStartHour);
				var lowRateStartMinute  = parseInt(app.connectedInfo.lowRateStartMinute);
				var highRateStartHour   = parseInt(app.connectedInfo.highRateStartHour);
				var highRateStartMinute = parseInt(app.connectedInfo.highRateStartMinute);
				var dateLow = new Date(0);
				var dateHigh = new Date(0);

				if (! isNaN(lowRateStartHour))
					dateLow.setHours(lowRateStartHour);
				if (! isNaN(lowRateStartMinute))
					dateLow.setMinutes(lowRateStartMinute);

				if (! isNaN(highRateStartHour))
					dateHigh.setHours(highRateStartHour);
				if (! isNaN(highRateStartMinute))
					dateHigh.setMinutes(highRateStartMinute);

				var timeLowStr = i18n.dateTime(dateLow.getTime(), i18n.time_yes | i18n.leading_0_yes);
				var timeHighStr = i18n.dateTime(dateHigh.getTime(), i18n.time_yes | i18n.hour_str_yes | i18n.leading_0_yes);

				lowRateHoursLabel.rightText = qsTr("%1 - %2").arg(timeLowStr).arg(timeHighStr);
			}
			lowRateHoursItem.visible = elecDualRate;
		} else {
			lowRateHoursItem.visible = false;
		}
	}

	function init() {
		app.zwaveDevicesUpdated.connect(updateStatus);
		app.usageDevicesInfoChanged.connect(updateStatus);
		app.connectedInfoChanged.connect(updateAnalogSection);
		app.usageDevicesInfoChanged.connect(updateAnalogSection);
		app.elecRateChanged.connect(updateAnalogSection);
		app.sensorConfigurationUpdated.connect(p.sensorConfigUpdateHandler);
	}

	function handleCanActivateSolarResponse(msg) {
		if (msg) {
			p.scsyncCanActivateSolar = msg.getArgument("CanActivateSolar") === "true";
		} else {
			console.log("timeout: request to retrieve CanActivateSolar");
		}
	}

	onShown: {
		zWaveUtils.getDevices();
		app.getCanActivateSolar(handleCanActivateSolarResponse);
		app.getSensorConfiguration();

		// Get meter configuration for ALL meter adapters
		app.getAllMeterConfigurations();

		updateStatus();

		//p.logSolarInstallConditions()
	}

	Component.onDestruction: {
		app.zwaveDevicesUpdated.disconnect(updateStatus);
		app.usageDevicesInfoChanged.disconnect(updateStatus);
		app.connectedInfoChanged.disconnect(updateAnalogSection);
		app.usageDevicesInfoChanged.disconnect(updateAnalogSection);
		app.maDevicesChanged.disconnect(updateAnalogSection);
		app.elecRateChanged.disconnect(updateAnalogSection);
		app.sensorConfigurationUpdated.disconnect(p.sensorConfigUpdateHandler);
	}

	anchors.fill: parent

	Connections {
		target: InputContext
		enabled: eMeterFrame.visible
		onInputItemChanged: p.ensureInputVisibility()
	}

	Column {
		id: labelContainer
		anchors {
			top: parent.top
			topMargin: designElements.vMargin20 + p.inputItemOffset
			left: parent.left
			leftMargin: Math.round(44 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(27 * horizontalScaling)
		}
		spacing: designElements.vMargin6

		Item {
			id: meterAdapterItem
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: meteradapterLabel

				leftText: qsTr("Meter modules")
				rightText: ""
				rightTextSize: qfont.bodyText

				anchors {
					left: parent.left
					right:meteradapterButton.left
					rightMargin: designElements.hMargin6
				}

				onClicked: meteradapterButton.clicked()
			}

			IconButton {
				id: meteradapterButton

				width: designElements.buttonSize
				iconSource: "qrc:/images/edit.svg"

				anchors {
					bottom: meteradapterLabel.bottom
					right: parent.right
				}

				bottomClickMargin: 3
				onClicked: {
					stage.openFullscreen(app.eMetersScreenUrl);
				}
			}
		}

		Item {
			id: repeaterItem
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: repeaterLabel

				leftText: qsTr("Repeaters")
				rightText: ""
				rightTextSize: qfont.bodyText

				anchors {
					left: parent.left
					right:repeaterButton.left
					rightMargin: designElements.hMargin6
				}

				onClicked: repeaterButton.clicked()
			}

			IconButton {
				id: repeaterButton
				width: designElements.buttonSize
				anchors {
					bottom: repeaterLabel.bottom
					right: parent.right
				}
				iconSource: "qrc:/images/edit.svg"
				topClickMargin: 3
				onClicked: {
					stage.openFullscreen(app.repeaterChangeScreenUrl);
				}
			}
		}

		Item {
			id: spacer
			width: parent.width
			height: Math.round(18 * verticalScaling)
			visible: lowRateHoursItem.visible
		}

		Item {
			id: lowRateHoursItem
			width: parent.width
			height: childrenRect.height
			visible: false

			SingleLabel {
				id: lowRateHoursLabel

				leftText: qsTr("Low rate hours on weekdays")
				rightText: ""
				rightTextSize: qfont.bodyText

				anchors {
					left: parent.left
					right: lowRateHoursButton.left
					rightMargin: designElements.hMargin6
				}
			}
			IconButton {
				id: lowRateHoursButton
				width: designElements.buttonSize
				iconSource: "qrc:/images/edit.svg"
				anchors {
					bottom: lowRateHoursLabel.bottom
					right: parent.right
				}
				topClickMargin: 3
				onClicked: {
					stage.openFullscreen(app.eMeterLowRateHoursScreenUrl);
				}
			}
		}

		Item {
			id: spacer2
			width: parent.width
			height: Math.round(18 * verticalScaling)
			visible: waterTariffLabel.visible
		}

		EditTextLabel {
			id: waterTariffLabel
			width: parent.width
			visible: p.hasWaterMetering

			labelText: qsTr("Water tariff") + " <font size=1>(" + qsTr("per m³") + ")</font>"
			labelTextFormat: Text.RichText
			leftTextAvailableWidth: width * 0.6
			prefilledText: i18n.number(app.waterTariff, 4, i18n.omit_trail_zeros)
			inputHints: Qt.ImhDigitsOnly
			showAcceptButton: true
			validator: DoubleValidator { bottom: 0.0001; top: 100; decimals: 4 }

			onInputAccepted: p.waterTariffSave(inputText)

			Text {
				id : currencyText
				anchors {
					right: parent.left
					rightMargin: (- parent.leftTextAvailableWidth) - designElements.hMargin10
					verticalCenter: parent.verticalCenter
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				color: colors._harry
				text: i18n.currency()
			}
		}

		Item {
			id: spacer3
			width: parent.width
			height: Math.round(18 * verticalScaling)
			visible: toonSolarSection.visible || installSolarItem.visible
		}

		Item {
			id: toonSolarSection
			width: parent.width
			height: childrenRect.height
			visible: !p.showSolarInstall && p.hasSolarMetering

			SingleLabel {
				id: estimatedGenerationLabel
				anchors {
					left: parent.left
					right: estimationEditButton.left
					rightMargin: designElements.hMargin6
				}
				leftText: qsTr("Estimated generation")
				rightText: "%1 %2".arg(app.estimatedGeneration).arg(qsTr("kWh per year"))
				rightTextSize: qfont.bodyText
			}

			IconButton {
				id: estimationEditButton
				anchors {
					right: parent.right
					top: estimatedGenerationLabel.top
				}
				iconSource: "qrc:/images/edit.svg"
				onClicked: {
					stage.openFullscreen(app.estimatedGenerationScreenUrl, {from: "notWizard", editing: true});
				}
			}
		}

		Item {
			id: installSolarItem
			width: parent.width
			height: childrenRect.height
			visible: p.showSolarInstall

			SingleLabel {
				id: installSolarLabel
				leftText: qsTr("Toon Solar");
				anchors {
					left: parent.left
					right: installSolarButton.left
					rightMargin: designElements.hMargin6
				}
			}
			StandardButton {
				id: installSolarButton
				anchors {
					right: parent.right
					top: installSolarLabel.top
				}
				height: installSolarLabel.height
				text: qsTr("Install")
				onClicked: stage.openFullscreen(app.solarInstalledScreenUrl)
			}
		}
	}
}
