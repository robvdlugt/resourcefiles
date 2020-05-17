import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0
import BasicUIControls 1.0

import "BoilerMonitorConstants.js" as Constants

Screen {
	id: boilerInfoOverviewScreen
	screenTitle: qsTr("screen_name")
	property BoilerMonitorApp app

	property url boilerInfoExplanationPopupUrl: "BoilerInfoExplanationPopup.qml"

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false

		if (args) {
			if (args.fetch) {
				state = "LOADING";
				// reset boiler profile data flag so we fetch it again
				app.backendDataReceived &= ~Constants.BACKEND_DATA.BOILER_PROFILE
				app.fetchDataFromBackend(false, fetchFinished);
			}
			if (args.page && args.page >= 0 && args.page < pageSelector.pageCount)
				pageSelector.navigateBtn(args.page);
			if (args.highlightField) {
				var field = qtUtils.getChildByName(container, args.highlightField)
				if (field && typeof field.highlight !== "undefined")
					field.highlight = true;
			}
		}
	}

	onHidden: screenStateController.screenColorDimmedIsReachable = true

	function fetchFinished(success) {
		state = "";
	}

	Rectangle {
		id: progressContainer
		height: Math.round(112 * verticalScaling)
		radius: designElements.radius
		anchors {
			top: parent.top
			topMargin: Math.round(22 * verticalScaling)
			right: parent.right
			rightMargin: Math.round(80 * horizontalScaling)
			left: parent.left
			leftMargin: anchors.rightMargin
		}
		color: colors.contentBackground

		Item {
			anchors.fill: parent
			visible: !app.apiError

			Text {
				id: overviewText
				anchors {
					verticalCenter: boilerMoreInfoButton.verticalCenter
					left: parent.left
					leftMargin: Math.round(24 * horizontalScaling)
					right: boilerMoreInfoButton.left
				}
				font {
					family: qfont.bold.name
					pixelSize: qfont.titleText
				}
				wrapMode: Text.WordWrap
				text: app.progress === 1 ? qsTr("boiler_profile_complete") : qsTr("boiler_profile_status").arg(Math.floor(app.progress * 100))
			}

			IconButton {
				id: boilerMoreInfoButton
				anchors {
					top: parent.top
					topMargin: designElements.vMargin20
					right: parent.right
					rightMargin: anchors.topMargin
				}
				iconSource: Qt.resolvedUrl("qrc:/images/info.svg");
				visible: !throbber.visible

				onClicked: qdialog.showDialog(qdialog.SizeLarge, qsTr("boiler_info_explanation_title"), boilerInfoExplanationPopupUrl);
			}

			Throbber {
				id: throbber
				anchors.centerIn: boilerMoreInfoButton
				anchors.fill: boilerMoreInfoButton
				visible: false
			}

			ProgressBar {
				id: progressBar
				anchors {
					bottom: parent.bottom
					bottomMargin: designElements.vMargin20
					left: parent.left
					leftMargin: anchors.bottomMargin
					right: parent.right
					rightMargin: anchors.leftMargin
				}
				progress: app.progress
			}
		}

		Item {
			anchors.fill: parent
			visible: app.apiError

			Image {
				id: errorIcon
				anchors {
					verticalCenter: parent.verticalCenter
					left: parent.left
					leftMargin: Math.round(24 * horizontalScaling)
				}
				source: "image://scaled/apps/boilerMonitor/drawables/wifi-error.svg"
			}

			Text {
				id: errorText
				anchors {
					verticalCenter: parent.verticalCenter
					left: errorIcon.right
					leftMargin: Math.round(24 * horizontalScaling)
					right: parent.right
					rightMargin: anchors.leftMargin
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				wrapMode: Text.WordWrap
				text: qsTr("error-api-unavailable-text")
			}
		}
	}

	Text {
		id: pageTitle
		anchors {
			top: progressContainer.bottom
			topMargin: designElements.vMargin20
			left: progressContainer.left
			right: progressContainer.right
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.bodyText
		}
		text: " "
	}

	Flickable {
		id: container
		anchors {
			top: pageTitle.baseline
			topMargin: designElements.vMargin15
			left: progressContainer.left
			leftMargin: -Math.round(30 * verticalScaling)
			right: progressContainer.right
			bottom: pageSelector.top
		}
		contentWidth: containerRow.width
		flickableDirection: Flickable.HorizontalFlick
		interactive: isNxt
		clip: true
		boundsBehavior: Flickable.StopAtBounds
		maximumFlickVelocity: 2000
		flickDeceleration: 4000

		Behavior on contentX {
			enabled: isNxt
			SmoothedAnimation {duration: 400}
		}

		onMovementEnded: {
			var newPage = pageSelector.currentPage;
			if (horizontalVelocity > 0 && contentX > ((pageSelector.currentPage + 0.3) * width))
				newPage++;
			else if(horizontalVelocity < 0 && contentX < ((pageSelector.currentPage - 0.3) * width))
				newPage--;
			pageSelector.navigateBtn(newPage);
		}

		Component.onCompleted: {
			updatePageCount()
			contentWidthChanged.connect(updatePageCount);
		}

		function updatePageCount() {
			pageSelector.pageCount = Math.ceil(container.contentWidth / container.width);
		}

		Row {
			id: containerRow
			height: parent.height

			Column {
				id: pageTechInfo
				width: container.width
				anchors.top: parent.top
				spacing: designElements.vMargin5
				property string title: qsTr("Technical information")

				InfoHeaderItem {
					id: boilerBrandInfo
					objectName: "boilerBrandField"
					enabled: globals.serviceCenterAvailable
					width: parent.width
					showIndicator: true
					indicatorOk: app.boilerBrandName ? true : false
					headerText: qsTr("brand_header")
					infoText: app.boilerBrandName ? app.boilerBrandName : "-"

					onEditInfo: stage.openFullscreen(app.boilerDataSelectScreenUrl)
				}

				InfoHeaderItem {
					id: boilerModelInfo
					objectName: "boilerModelField"
					enabled: globals.serviceCenterAvailable && app.boilerBrandName
					width: parent.width
					showIndicator: true
					indicatorOk: app.boilerModelName ? true : false
					headerText: qsTr("type_header")
					infoText: app.boilerModelName ? app.boilerModelName : "-"

					onEditInfo: stage.openFullscreen(app.boilerDataSelectScreenUrl, {"brandId": app.boilerInfo.brandId});
				}

				InfoHeaderItem {
					id: boilerYearInfo
					objectName: "boilerYearField"
					enabled: globals.serviceCenterAvailable
					width: parent.width
					showIndicator: true
					indicatorOk: app.boilerInfo.productionYear > 0 ? true : false
					headerText: qsTr("year_header")
					infoText: {
						if (app.boilerInfo.productionYear > 0)
							app.boilerInfo.productionYear
						else if (app.boilerInfo.productionYear === 0)
							qsTr("I don't know")
						else
							"-"
					}

					onEditInfo: stage.openFullscreen(app.boilerProdYearSelectScreen);
				}
			}

			Item {
				id: pageServiceInfo
				width: container.width
				height: childrenRect.height
				anchors.top: parent.top
				property string title: qsTr("Service information")

				Column {
					width: parent.width
					spacing: designElements.vMargin5

					InfoHeaderItem {
						id: boilerLastMaintenanceInfo
						objectName: "boilerLastMaintenanceField"
						enabled: globals.serviceCenterAvailable
						width: parent.width
						showIndicator: true
						indicatorOk: app.lastMaintenance ? true : false
						headerText: qsTr("lastMaintenance_header")
						infoText: {
							if (!app.lastMaintenance)
								"-"
							else if (app.lastMaintenance.getFullYear() === 1970)
								qsTr("Never") + " / " + qsTr("I don't know")
							else
								i18n.monthsFull[app.lastMaintenance.getMonth()] + " " + app.lastMaintenance.getFullYear()
						}

						onEditInfo: stage.openFullscreen(app.boilerLastMaintenanceScreenUrl);
					}

					InfoHeaderItem {
						id: serviceIntervalInfo
						objectName: "serviceIntervalField"
						enabled: globals.serviceCenterAvailable
						visible: app.serviceConfiguration["enableServiceInterval"]
						width: parent.width
						showIndicator: true
						indicatorOk: app.boilerInfo.serviceInterval > 0
						headerText: qsTr("service_interval_header")
						infoText: {
							if (app.boilerInfo.serviceInterval > 0)
								qsTr("Every %n year(s)", "", Math.floor(app.boilerInfo.serviceInterval / 365))
							else if (app.boilerInfo.serviceInterval === 0)
								qsTr("Never")
							else
								"-"
						}

						onEditInfo: stage.openFullscreen(app.boilerMaintenanceIntervalScreenUrl);
					}

					InfoHeaderItem {
						id: maintenanceProviderInfo
						objectName: "maintenanceProviderField"
						enabled: globals.serviceCenterAvailable
						visible: app.serviceConfiguration["enableServiceProvider"]
						width: parent.width
						showIndicator: true
						indicatorOk: app.boilerInfo.maintenanceProviderId > 0
						headerText: qsTr("service_provider_header")
						infoText: {
							var provider = app.getMaintenanceProviderById(app.boilerInfo.maintenanceProviderId);
							provider ? provider.shortDescription : "-";
						}

						onEditInfo: stage.openFullscreen(app.boilerMaintenanceProviderScreenUrl);
					}
				}
			}

			Item {
				id: pagePersonalInfo
				width: container.width
				height: childrenRect.height
				anchors.top: parent.top
				visible: personalInfoColumn.height > 0
				property string title: qsTr("Personal information")

				Column {
					id: personalInfoColumn
					width: parent.width
					spacing: designElements.vMargin20

					InfoHeaderItem {
						id: phoneNumbersInfo
						objectName: "phoneNumbersField"
						enabled: globals.serviceCenterAvailable
						visible: app.serviceConfiguration["enablePhoneNumbers"]
						width: parent.width
						showIndicator: true
						headerText: qsTr("phone_numbers_header")
						infoText: app.getPhoneNumberInfoText()
						indicatorOk: infoText !== "-"

						onEditInfo: stage.openFullscreen(app.boilerPhoneNumberScreenUrl);
					}

					InfoHeaderItem {
						id: boilerAdviceInfo
						objectName: "boilerAdviceField"
						enabled: app.consentSet !== undefined && globals.serviceCenterAvailable
						visible: !app.serviceConfiguration["automaticConsent"]
						width: parent.width
						headerText: qsTr("boiler_advice_header")
						showIndicator: false
						onlyLabel: true

						OnOffToggle {
							id: toggle
							anchors {
								verticalCenter: parent.verticalCenter
								right: parent.right
								rightMargin: designElements.hMargin10
							}
							useOnOffTexts: false
							rightText: qsTr("On")
							leftText: qsTr("Off")
							useBoldChangeForLeftRight: true
							isSwitchedOn: app.consentSet === true
							enabled: parent.enabled
							selectionTrigger: "None"
							unselectionTrigger: "None"

							onClicked: if (selected) app.confirmDisableAdvice({"saveFinished": function(success) { if(success) stage.navigateHome() } });
						}
					}
				}
			}
		}

		function changePage(page) {
			if (page >= pageSelector.pageCount)
				return;
			var newX = page * container.width;
			container.contentX = newX;
			var currentItem = containerRow.childAt(newX, 0);
			if (currentItem && currentItem.title)
				pageTitle.text = currentItem.title;
		}
	}

	DottedSelector {
		id: pageSelector
		anchors {
			bottom: parent.bottom
			left: progressContainer.left
			right: progressContainer.right
		}
		leftArrowEnabled: currentPage != 0
		rightArrowEnabled: currentPage != pageCount - 1
		onNavigate: container.changePage(page)
	}

	states: [
		State {
			name: "LOADING"
			PropertyChanges { target: overviewText; text: qsTr("retrieving-boiler-profile") }
			PropertyChanges { target: throbber; visible: true }
			PropertyChanges { target: containerRow; enabled: false }
		}
	]
}
