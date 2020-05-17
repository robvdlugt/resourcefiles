import QtQuick 2.1

import qb.base 1.0
import BasicUIControls 1.0;
import qb.components 1.0

import "ManualConfigurationScreen.js" as Config
import "Constants.js" as Constants

Screen {
	id: root

	isSaveCancelDialog: true
	screenTitle: qsTr("Install meter adapter")

	property string uuid: ""
	property variant capabilityList: []

	property EMetersSettingsApp app

	property variant gasSensors: ['analogGas', 'p1Gas']
	property variant heatSensors: ['analogHeat']
	property variant solarSensors: ['analogSolar']
	property variant elecSensors: ['analogElec', 'laserElec', 'p1Elec']
	property variant waterSensors: ['analogWater']

	property int previousSensorsPage: -1

	QtObject {
		id: p

		property bool elecAvailable: false
		property bool solarAvailable: false
		property bool gasAvailable: false
		property bool heatAvailable: false
		property bool waterAvailable: false

		function storeAvailableSensorsList(devices)
		{
			elecAvailable = false;
			solarAvailable = false;
			gasAvailable = false;
			heatAvailable = false;
			waterAvailable = false;
			var deviceNode = devices.getChild("device");
			// Get displayed resource node
			var resourceNode, sensor, type;
			for (resourceNode = deviceNode.getChild("resource"); resourceNode; resourceNode = resourceNode.next) {
				if ("elec" === resourceNode.getAttribute('name')) {
					for (sensor = resourceNode.getChild("sensor"); sensor; sensor = sensor.next) {
						for (type = sensor.getChild("type"); type; type = type.next) {
							if (type.text === "Import") {
								elecAvailable |= (type.getAttribute("state") === "eligible");
							} else if (type.text === "Export") {
								solarAvailable |= (type.getAttribute("state") === "eligible");
							} else if (type.text === "ImportExport") {
								elecAvailable |= (type.getAttribute("state") === "eligible");
								solarAvailable |= (type.getAttribute("state") === "eligible");
							}
						}
					}
				} else if ("gas" === resourceNode.getAttribute('name')) {
					for (sensor = resourceNode.getChild("sensor"); sensor; sensor = sensor.next) {
						for (type = sensor.getChild("type"); type; type = type.next) {
							gasAvailable |= (type.getAttribute("state") === "eligible");
						}
					}
				} else if ("heat" === resourceNode.getAttribute('name')) {
					for (sensor = resourceNode.getChild("sensor"); sensor; sensor = sensor.next) {
						for (type = sensor.getChild("type"); type; type = type.next) {
							heatAvailable |= (type.getAttribute("state") === "eligible");
						}
					}
				} else if ("water" === resourceNode.getAttribute('name')) {
					for (sensor = resourceNode.getChild("sensor"); sensor; sensor = sensor.next) {
						for (type = sensor.getChild("type"); type; type = type.next) {
							waterAvailable |= (type.getAttribute("state") === "eligible");
						}
					}
				}
			}
		}
	}

	function getMeasureCapabilitiesResponse(response) {
		var capabilities = [];
		for (var device = response.getArgumentXml("device"); device; device = device.next) {
			var deviceUuid = device.getChildText("deviceUuid");
			if (deviceUuid === uuid)
			{
				var node = device.getChild("capabilities");
				for (var capability = node.getChild("capability"); capability; capability = capability.next) {
					capabilities.push(capability.text);
				}
				capabilityList = capabilities;
			}
		}

		app.sensorConfigurationUpdated.connect(update);
		app.getSensorConfiguration();
	}

	function makeSensorsList(response) {
		var devicesNode = response.getArgumentXml("devices");
		var deviceNode = devicesNode.getChild("device");

		// Traverse through entire device node to the deepest element and make the available sensors list
		var sensorsList = [ [], [], [], [], [] ];
		for (var resourceNode = deviceNode.getChild("resource"); resourceNode; resourceNode = resourceNode.next) {
			var resourceName = resourceNode.getAttribute('name');

			for (var sensorNode = resourceNode.getChild("sensor"); sensorNode; sensorNode = sensorNode.next) {
				var sensorName = sensorNode.getAttribute('name');

				for (var typeNode = sensorNode.getChild("type"); typeNode; typeNode = typeNode.next) {
					var sensorType = typeNode.text;

					var sensor = { 'resource': resourceName, 'type': sensorType, 'name': sensorName, 'modelItem': null };
					if ('elec' === resourceName && 'Export' !== sensorType) {
						switch(sensorName) {
						default: //break;
						case 'analog1':
							sensor.modelItem = elecSensorList.getModelItem(0);
							sensorsList[0][0] = sensor;
							break;
						case 'laser':
							sensor.modelItem = elecSensorList.getModelItem(1);
							sensorsList[0][1] = sensor;
							break;
						case 'p1':
							sensor.modelItem = elecSensorList.getModelItem(2);
							sensorsList[0][2] = sensor;
							break;
						}
					} else if ('gas' === resourceName) {
						switch(sensorName) {
						default: //break;
						case 'analog2':
							sensor.modelItem = gasSensorList.getModelItem(0);
							sensorsList[1][0] = sensor;
							break;
						case 'p1':
							sensor.modelItem = gasSensorList.getModelItem(1);
							sensorsList[1][1] = sensor;
							break;
						}
					} else if ('heat' === resourceName) {
						switch(sensorName) {
						default: //break;
						case 'analog2':
							sensor.modelItem = heatSensorList.getModelItem(0);
							sensorsList[2][0] = sensor;
							break;
						}
					} else if ('elec' === resourceName && 'Export' === sensorType) {
						switch(sensorName) {
						default: //break;
						case 'analog1':
							sensor.modelItem = solarSensorList.getModelItem(0)
							sensorsList[3][0] = sensor;
							break;
						}
					} else if ('water' === resourceName) {
						switch(sensorName) {
						default: //break;
						case 'analog2':
							sensor.modelItem = waterSensorList.getModelItem(0);
							sensorsList[4][0] = sensor;
							break;
						}
					}
				} // for types...
			} // for sensors...
		} // for resources...
		return sensorsList;
	}

	function checkCurrentConfiguration() {
		// Check if the current configuration differs from the saved one.
		var changed = false;
		var indexes = getSensorPagesIndexes(getSensorsSavedConfiguration());
		for(var sensor = 0; sensor < indexes.length; sensor++) {
			if ((changed = (indexes[sensor] !== sensorPages.children[sensor].children[1/*RadioList*/].currentIndex)))
				break;
		}

		// Check the configuration only if there is a transition to the next page.
		//if (dotSelector.currentPage > previousSensorsPage) {
			var sensorConfigElements = Config.sensorsList;

			// Reset the selections on all the sensors pages from the current one (not including) to the latest. Take
			// the sensors configuration in the range from the first to the current page and send it to the driver.
			var configuredSensors = [];
			var selectedCount = 0;
			for (var child = 0; child < checkboxList.children.length; child++) {
				if (checkboxList.children[child].selected) {
					selectedCount++;
					var radioList = sensorPages.children[child].children[1];
					var item;
					if (sensorConfigElements[child].length === 1) {
						// we can preselect this sensor
						console.log("Push only available sensor");
						item = sensorConfigElements[child][0];
						configuredSensors.push(item);
					} else if (selectedCount < dotSelector.currentPage) {
						item = sensorConfigElements[child][radioList.currentIndex];
						configuredSensors.push(item);
					} else {
						//console.log("reset: " + sensorConfigElements[child][0].resource + ", " + change.toString());
						if (changed)
							radioList.currentIndex = -1;
					}
				}
			}
			app.getAvailableSensorsForConfiguration(uuid, configuredSensors, onGetSensorsConfiguration);

			// Receiving response might take a while so we disable the sensor pages in order to avoid possible user modifications
			// in the meantime.
			sensorPages.enabled = false;
		//} else {
			// No moving to the next sensor page detected
			//update();
		//}
		previousSensorsPage = dotSelector.currentPage;
	}



	function onGetSensorsConfiguration(response) {
		if (!response) {
			// Leave the sensor page disabled
			return;
		}
		console.log(response.stringContent);
		var success = response.getArgument("success") === "true" ? true : false;
		if (!success) {
			// Leave the sensor page disabled. There is a logical error - either invalid request was sent or the driver returned bad response.
			return;
		}

		sensorPages.enabled = true;

		p.storeAvailableSensorsList(response.getArgumentXml("devices"));

		// Get currently displayed resource
		var displayedResource;
		var selectedCount = 0;
		for (var child = 0; child < checkboxList.children.length; child++) {
			if (checkboxList.children[child].selected) {
				selectedCount++;
				if (selectedCount === dotSelector.currentPage) {
					switch(child) {
					case 0: displayedResource = 'elec'; break;
					case 1: displayedResource = 'gas'; break;
					case 2: displayedResource = 'heat'; break;
					case 3: displayedResource = 'elec'; break; // solar
					case 4: displayedResource = 'water'; break;
					}
					//console.log("current page: " + displayedResource);
				}
			}
		}

		var devicesNode = response.getArgumentXml("devices");
		var deviceNode = devicesNode.getChild("device");

		// Get displayed resource node
		var resourceNode;
		for (resourceNode = deviceNode.getChild("resource"); resourceNode; resourceNode = resourceNode.next) {
			if (displayedResource === resourceNode.getAttribute('name'))
				break;
		}
		if (!resourceNode) {
			update();
			return;
		}

		// Enable/disable sensors that are/are not eligible.
		var sensorsList = Config.sensorsList;
		for (var sensorNode = resourceNode.getChild("sensor"); sensorNode; sensorNode = sensorNode.next) {
			var sensorName = sensorNode.getAttribute('name');

			for (var typeNode = sensorNode.getChild("type"); typeNode; typeNode = typeNode.next) {
				var sensorType = typeNode.text;

				var resource;
				if ('elec' === displayedResource && 'Export' !== sensorType) {
					resource = sensorsList[0];
				} else if ('gas' === displayedResource) {
					resource = sensorsList[1];
				} else if ('heat' === displayedResource) {
					resource = sensorsList[2];
				} else if ('elec' === displayedResource && 'Export' === sensorType) {
					resource = sensorsList[3];
				} else if ('water' === displayedResource) {
					resource = sensorsList[4];
				}

				for(var i = 0; i < resource.length; i++) {
					var sensor = resource[i];
					if (sensor && sensor.type === sensorType && sensor.name === sensorName) {
						var sensorState = typeNode.getAttribute("state");
						var sensorEnabled = 'eligible' === sensorState || 'selected' === sensorState ? true : false;

						//console.log("resource: " + displayedResource + ", " + sensorName + ", " + sensorType + ", " + sensorEnabled);

						var controlGroup = sensor.modelItem.controlGroup;
						// If the current radio item is selected and is going to be disabled then unselect it first
						if (!sensorEnabled && controlGroup.currentControlId === i)
							controlGroup.currentControlId = -1;
						sensor.modelItem.itemEnabled = sensorEnabled;
					}
				}

			} // for type nodes...
		} // for sensor nodes...

		update();
	}

	function update() {
		// Enable the checkboxes
		gasCheckbox.enabled = (app.checkMeasureCapability(capabilityList, gasSensors) && app.checkAvailableMeasureType(uuid, gasSensors) && (gasCheckbox.selected || p.gasAvailable));
		elecCheckbox.enabled = (app.checkMeasureCapability(capabilityList, elecSensors) && app.checkAvailableMeasureType(uuid, elecSensors) && (elecCheckbox.selected || p.elecAvailable));
		heatCheckbox.enabled = (app.checkMeasureCapability(capabilityList, heatSensors) && app.checkAvailableMeasureType(uuid, heatSensors) && (heatCheckbox.selected || p.heatAvailable));
		solarCheckbox.enabled = (app.checkMeasureCapability(capabilityList, solarSensors) && app.checkAvailableMeasureType(uuid, solarSensors) && (solarCheckbox.selected || p.solarAvailable));
		waterCheckbox.enabled = (app.checkMeasureCapability(capabilityList, waterSensors) && app.checkAvailableMeasureType(uuid, waterSensors) && (waterCheckbox.selected || p.waterAvailable));

		// update pagecount according to checked checkboxes
		var selectedCount = 0;
		for (var child = 0; child < checkboxList.children.length; child++)
			if (checkboxList.children[child].selected)
				selectedCount++;
		dotSelector.pageCount = selectedCount + 1;

		var canSave = (selectedCount == 0);
		var dotSelectorArrowRightEnabled = (dotSelector.currentPage == 0);

		// make the nth page visible
		var enabledBoxes = 0;
		for (var type = 0; type < checkboxList.children.length; type++) {
			var boxEnabled = checkboxList.children[type].selected;
			if (boxEnabled)
				enabledBoxes++;

			var sensorPageVisible = (enabledBoxes == dotSelector.currentPage) && boxEnabled;
			sensorPages.children[type].visible = sensorPageVisible;
			if (sensorPageVisible) {
				var radioList = sensorPages.children[type].children[1];

				dotSelectorArrowRightEnabled = radioList.currentIndex !== -1

				if (!dotSelectorArrowRightEnabled) {
					// Check if all the items are disabled. If so, then the selector right arrow needs to be enabled
					// otherwise an user gets stuck on this page since she cannot select anything.
					var i = 0;
					for(; i < radioList.count; i++) {
						if (radioList.getModelItem(i).itemEnabled)
							break;
					}
					dotSelectorArrowRightEnabled = radioList.count === i;
				}

				// set the enabledness of the save button
				if (dotSelector.currentPage === (dotSelector.pageCount - 1) && dotSelectorArrowRightEnabled)
					canSave = true;
			}
		}

		dotSelector.rightArrowEnabled = dotSelectorArrowRightEnabled;
		if (canSave)
			root.enableSaveButton();
		else
			root.disableSaveButton();
	}

	function getSensorsSavedConfiguration() {
		var sensors;
		for (var i = app.maConfiguration.length - 1; i >= 0; i--)
			if (app.maConfiguration[i].deviceUuid === uuid)
				sensors = app.maConfiguration[i].sensors;
		return sensors;
	}

	function getSensorPagesIndexes(sensors) {
		var indexes = new Array(sensorPages.children.length);
		for(var i = 0; i < indexes.length; i++)
			indexes[i] = -1;

		for (var sensorIdx in sensors) {
			var sensor = sensors[sensorIdx];
			if (sensor.indexOf("Elec") > 0)
				indexes[0] = elecSensors.indexOf(sensor);
			else if (sensor.indexOf("Gas") > 0)
				indexes[1] = gasSensors.indexOf(sensor);
			else if (sensor.indexOf("Heat") > 0)
				indexes[2] = heatSensors.indexOf(sensor);
			else if (sensor.indexOf("Solar") > 0)
				indexes[3] = solarSensors.indexOf(sensor);
			else if (sensor.indexOf("Water") > 0)
				indexes[4] = waterSensors.indexOf(sensor);
		}
		return indexes;
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		if (args && args.uuid) {
			uuid = args.uuid;

			Config.sensorsList = null;
			app.getAvailableSensorsForConfiguration(uuid, [], function (response) {
				Config.sensorsList = makeSensorsList(response);
				app.getMeasureCapabilities(uuid, getMeasureCapabilitiesResponse);
				checkCurrentConfiguration();
			});

			var currentStatus = app.getInformationSourceStatusInt(uuid);
			gasCheckbox.selected = currentStatus & Constants.CONFIG_STATUS.GAS;
			elecCheckbox.selected = currentStatus & Constants.CONFIG_STATUS.ELEC;
			solarCheckbox.selected = currentStatus & Constants.CONFIG_STATUS.SOLAR;
			heatCheckbox.selected = currentStatus & Constants.CONFIG_STATUS.HEAT;
			waterCheckbox.selected = currentStatus & Constants.CONFIG_STATUS.WATER;

			var indexes = getSensorPagesIndexes(getSensorsSavedConfiguration());
			for(var sensor = 0; sensor < indexes.length; sensor++) {
				sensorPages.children[sensor].children[1/*RadioList*/].currentIndex = indexes[sensor];
			}
		}
		disableSaveButton();
	}

	onHidden: {
		Config.sensorsList = null; // free some resources
		app.sensorConfigurationUpdated.disconnect(update);
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		var gasIndex = gasCheckbox.selected ? gasSensorList.currentIndex : -1;
		var heatIndex = heatCheckbox.selected ? heatSensorList.currentIndex : -1;
		var elecIndex = elecCheckbox.selected ? elecSensorList.currentIndex : -1;
		var solarIndex = solarCheckbox.selected ? solarSensorList.currentIndex : -1;
		var waterIndex = waterCheckbox.selected ? waterSensorList.currentIndex : -1;
		var sensors = [];
		var status;
		var i = 0;

		if(gasIndex >= 0 && gasIndex < gasSensors.length) {
			sensors.push(gasSensors[gasIndex]);
			i += Constants.CONFIG_STATUS.GAS;
		}
		if(elecIndex >= 0 && elecIndex < elecSensors.length) {
			sensors.push(elecSensors[elecIndex]);
			i += Constants.CONFIG_STATUS.ELEC;
		}
		if(solarIndex >= 0 && solarIndex < solarSensors.length) {
			sensors.push(solarSensors[solarIndex]);
			i += Constants.CONFIG_STATUS.SOLAR;
		}
		if(heatIndex >= 0 && heatIndex < heatSensors.length) {
			sensors.push(heatSensors[heatIndex]);
			i += Constants.CONFIG_STATUS.HEAT;
		}
		if(waterIndex >= 0 && waterIndex < waterSensors.length) {
			sensors.push(waterSensors[waterIndex]);
			i += Constants.CONFIG_STATUS.WATER;
		}

		status = app.getMaConfigurationStatusString(i);

		var device = {
			'deviceUuid': uuid,
			'sensors': sensors,
			'status': status,
			'statusInt': i
		};

		// Save configuration
		var devices = app.maConfiguration;
		for(i = 0; i < devices.length; i++) {
			if(uuid === devices[i].deviceUuid) {
				devices.splice(i,1);
			}
		}

		devices.push(device);
		app.maConfiguration = devices;
		app.sendSensorConfiguration(devices);
	}

	DottedSelector {
		id: dotSelector
		width: Math.round(488 * horizontalScaling)
		visible: pageCount > 1
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: 0
		}
		pageCount: 0
		leftArrowVisible: currentPage > 0
		rightArrowVisible: rightArrowEnabled && currentPage < pageCount - 1
		onNavigate: root.checkCurrentConfiguration()
	}

	Item {
		id: manualConfigItem
		anchors {
			top: parent.top
			bottom: dotSelector.top
			left: parent.left
			right: parent.right
		}
		visible: dotSelector.currentPage == 0

		Text {
			id: bodyText

			wrapMode: Text.WordWrap
			color: colors.localAccesBody
			text: qsTr("manual_configuration")

			font.pixelSize: qfont.bodyText
			font.family: qfont.regular.name

			anchors {
				top: parent.top
				topMargin: Math.round(60 * verticalScaling)
				horizontalCenter: parent.horizontalCenter
			}
		}

		Column {
			id: checkboxList
			width: Math.round(200 * horizontalScaling)
			height: Math.round(180 * verticalScaling)
			spacing: Math.round(12 * verticalScaling)

			anchors {
				horizontalCenter: parent.horizontalCenter
				top: bodyText.baseline
				topMargin: Math.round(40 * verticalScaling)
			}

			StandardCheckBox {
				id: elecCheckbox
				enabled: false
				text: qsTr("Electricity")
				onSelectedChangedByUser: root.checkCurrentConfiguration()
			}

			StandardCheckBox {
				id: gasCheckbox
				enabled: false
				visible: globals.productOptions["gas"] === "1"
				text: qsTr("Gas")
				onSelectedChangedByUser: root.checkCurrentConfiguration()
			}

			StandardCheckBox {
				id: heatCheckbox
				enabled: false
				visible: globals.productOptions["district_heating"] === "1"
				text: qsTr("Heat")
				onSelectedChangedByUser: root.checkCurrentConfiguration()
			}

			StandardCheckBox {
				id: solarCheckbox
				enabled: false
				visible: globals.productOptions["solar"] === "1" && feature.appSolarEnabled()
				text: qsTr("Solar")
				onSelectedChangedByUser: root.checkCurrentConfiguration()
			}

			StandardCheckBox {
				id: waterCheckbox
				enabled: false
				visible: feature.featWaterInsightsEnabled()
				text: qsTr("Water")
				onSelectedChangedByUser: root.checkCurrentConfiguration()
			}
		}
	}

	Item {
		id: sensorPages
		visible: dotSelector.currentPage > 0

		anchors {
			top: parent.top
			bottom: dotSelector.top
			left: parent.left
			right: parent.right
		}

		Column {
			id: elecWrapper
			visible: false

			spacing: designElements.vMargin10

			anchors {
				top: parent.top
				topMargin: Math.round(12 * verticalScaling)
				left: parent.left
				right: parent.right
			}

			Text {
				id: elecMeterText
				anchors.horizontalCenter: parent.horizontalCenter
				wrapMode: Text.WordWrap
				color: colors.localAccesBody
				font.pixelSize: qfont.bodyText
				font.family: qfont.regular.name
				text: qsTr("Indicate how the meter module is connected to the power meter.")
			}

			RadioButtonList {
				id: elecSensorList
				width: Math.round(500 * horizontalScaling)
				height: Math.round(200 * verticalScaling)
				anchors.horizontalCenter: parent.horizontalCenter
				listDelegate: DescriptiveRadioButton {
					width: parent.width
					controlGroup: model.controlGroup
					iconSource: model.iconSource
					caption: model.connCaption
					description: model.connDesc
					enabled: model.itemEnabled
					kpiId: "elec sensor connection radioButton" + index
				}

				Component.onCompleted: {
					addCustomItem({iconSource: "drawables/kwh_analog.svg", connCaption: qsTr("Analog sensor connection"), connDesc: qsTr("Digital or analog connection")});
					addCustomItem({iconSource: "drawables/kwh_laser.svg", connCaption: qsTr("Laser sensor connection"), connDesc: qsTr("Digital or analog connection with plexiglas box")});
					addCustomItem({iconSource: "drawables/smartmeter.svg", connCaption: qsTr("P1 sensor connection"), connDesc: qsTr("Dutch smart meter connection")});
					forceLayout();
					currentIndex = -1;
					setItemEnabled(0, false);
					setItemEnabled(1, false);
					setItemEnabled(2, false);
				}

				onCurrentIndexChanged: root.update()
			}
		}

		Column {
			id: gasWrapper
			visible: false

			spacing: designElements.vMargin10

			anchors {
				left: parent.left
				right: parent.right
				top: parent.top
				topMargin: Math.round(12 * verticalScaling)
			}

			Text {
				id: gasmeterText
				anchors.horizontalCenter: parent.horizontalCenter
				wrapMode: Text.WordWrap
				color: colors.localAccesBody
				font.pixelSize: qfont.bodyText
				font.family: qfont.regular.name
				text: qsTr("Indicate how the meter module is connected to the gas meter.")
			}

			RadioButtonList {
				id: gasSensorList
				width: Math.round(500 * horizontalScaling)
				height: Math.round(110 * verticalScaling)
				anchors.horizontalCenter: parent.horizontalCenter
				listDelegate: DescriptiveRadioButton {
					width: parent.width
					controlGroup: model.controlGroup
					iconSource: model.iconSource
					caption: model.connCaption
					description: model.connDesc
					enabled: model.itemEnabled
					kpiId: "gas sensor connection radioButton" + index
				}

				Component.onCompleted: {
					addCustomItem({iconSource: "drawables/m3_analog.svg", connCaption: qsTr("Analog sensor connection"), connDesc: qsTr("Digital or analog connection")});
					addCustomItem({iconSource: "drawables/smartmeter.svg", connCaption: qsTr("P1 sensor connection"), connDesc: qsTr("Dutch smart meter connection")});
					forceLayout();
					currentIndex = -1;
					setItemEnabled(0, false);
					setItemEnabled(1, false);
				}

				onCurrentIndexChanged: root.update()
			}
		}

		Column {
			id: heatWrapper
			visible: false

			spacing: designElements.vMargin10

			anchors {
				left: parent.left
				right: parent.right
				top: parent.top
				topMargin: Math.round(12 * verticalScaling)
			}

			Text {
				id: heatMeterText
				anchors.horizontalCenter: parent.horizontalCenter
				wrapMode: Text.WordWrap
				color: colors.localAccesBody
				font.pixelSize: qfont.bodyText
				font.family: qfont.regular.name
				text: qsTr("Indicate how the meter module is connected to the heat meter.")
			}

			RadioButtonList {
				id: heatSensorList
				width: Math.round(500 * horizontalScaling)
				height: Math.round(110 * verticalScaling)
				anchors.horizontalCenter: parent.horizontalCenter
				listDelegate: DescriptiveRadioButton {
					width: parent.width
					controlGroup: model.controlGroup
					iconSource: model.iconSource
					caption: model.connCaption
					description: model.connDesc
					enabled: model.itemEnabled
					kpiId: "heat sensor connection radioButton" + index
				}

				Component.onCompleted: {
					addCustomItem({iconSource: "drawables/gj.svg", connCaption: qsTr("Analog sensor connection"), connDesc: qsTr("Every heat meter")});
					forceLayout();
					currentIndex = -1;
					setItemEnabled(0, false);
				}

				onCurrentIndexChanged: root.update()
			}
		}

		Column {
			id: solarWrapper
			visible: false

			spacing: designElements.vMargin10

			anchors {
				left: parent.left
				right: parent.right
				top: parent.top
				topMargin: Math.round(12 * verticalScaling)
			}

			Text {
				id: solarMeterText
				anchors.horizontalCenter: parent.horizontalCenter
				wrapMode: Text.WordWrap
				color: colors.localAccesBody
				font.pixelSize: qfont.bodyText
				font.family: qfont.regular.name
				text: qsTr("Indicate how the meter module is connected to the solar meter.")
			}

			RadioButtonList {
				id: solarSensorList
				width: Math.round(500 * horizontalScaling)
				height: Math.round(110 * verticalScaling)
				anchors.horizontalCenter: parent.horizontalCenter
				listDelegate: DescriptiveRadioButton {
					width: parent.width
					controlGroup: model.controlGroup
					iconSource: model.iconSource
					caption: model.connCaption
					description: model.connDesc
					enabled: model.itemEnabled
					kpiId: "solar sensor connection radioButton" + index
				}

				Component.onCompleted: {
					addCustomItem({iconSource: "drawables/kwh_analog.svg", connCaption: qsTr("Analog sensor connection"), connDesc: qsTr("Digital or analog connection")});
					forceLayout();
					currentIndex = -1;
					setItemEnabled(0, false);
				}

				onCurrentIndexChanged: root.update()
			}
		}

		Column {
			id: waterWrapper
			visible: false

			spacing: designElements.vMargin10

			anchors {
				left: parent.left
				right: parent.right
				top: parent.top
				topMargin: Math.round(12 * verticalScaling)
			}

			Text {
				id: waterMeterText
				anchors.horizontalCenter: parent.horizontalCenter
				wrapMode: Text.WordWrap
				color: colors.localAccesBody
				font.pixelSize: qfont.bodyText
				font.family: qfont.regular.name
				text: qsTr("Indicate how the meter module is connected to the water meter.")
			}

			RadioButtonList {
				id: waterSensorList
				width: Math.round(500 * horizontalScaling)
				height: Math.round(110 * verticalScaling)
				anchors.horizontalCenter: parent.horizontalCenter
				listDelegate: DescriptiveRadioButton {
					width: parent.width
					controlGroup: model.controlGroup
					iconSource: model.iconSource
					caption: model.connCaption
					description: model.connDesc
					enabled: model.itemEnabled
					kpiId: "water sensor connection radioButton" + index
				}

				Component.onCompleted: {
					addCustomItem({iconSource: "drawables/m3.svg", connCaption: qsTr("Analog sensor connection"), connDesc: qsTr("Every water meter")});
					forceLayout();
					currentIndex = -1;
					setItemEnabled(0, false);
				}

				onCurrentIndexChanged: root.update()
			}
		}
	}
}
