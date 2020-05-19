import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

Screen {
	id: benchmarkScreen

	QtObject {
		id: p

		property bool loading: true
		property variant units: ["kWh","m³","GJ"]
		property variant modes: ["elec", "gas", "heat"]
		property string  dataMode: "elec"
		property variant periods: ["day", "week", "month"]
		property string  dataPeriod: "day"
		property int dataIndex: -1
		property int hoursTillData

		property bool noData: app.benchmarkData[p.dataMode] ? false : true
		property string lastSampleTime: ""
		property string percentile: ""
		property string averageUsage: ""
		property string lowUsage: ""
		property string usage: ""
		property string compareToCount: ""

		property url friendsPopupSource: "FriendsPopup.qml"
		property url friendsDataPopupUrl: "FriendsDataPopup.qml"
	}

	function init() {
		setTopLeftTabs();
		bottomTabBar.addItem(qsTr("Day"));
		bottomTabBar.addItem(qsTr("Week"));
		bottomTabBar.addItem(qsTr("Month"));

		globals.productOptionsChanged.connect(setTopLeftTabs);
	}

	function setTopLeftTabs() {
		powerTabButton.visible = globals.productOptions['electricity'] === "1";
		gasTabButton.visible = globals.productOptions['gas'] === "1";
	}

	function setDateSelectorMode(tabIndex) {
		if (tabIndex < 0) return;
		var maxDate = new Date();
		switch(tabIndex) {
		case 0:
			dateSelector.mode = DateSelectorComponent.MODE_DAY;
			maxDate.setDate(maxDate.getDate() - 1);
			break;
		case 1:
			dateSelector.mode = DateSelectorComponent.MODE_WEEK;
			maxDate.setDate(maxDate.getDate() - 7);
			break;
		case 2:
			dateSelector.mode = DateSelectorComponent.MODE_MONTH;
			maxDate.setMonth(maxDate.getMonth() - 1);
			break;
		}

		dateSelector.periodMaximum = maxDate;
		dateSelector.periodStart = maxDate;
	}

	function calculateDataIndex(lastSampleT) {
		var periodStartDate = dateSelector.periodStart;
		var lastSampleDate = new Date();
		var dataIndex = -1;

		// lastSampleT is current date set always at midnight, but data is from yesterday so set one day back
		lastSampleDate.setTime(lastSampleT);
		lastSampleDate.setHours(-12);

		if ( periodStartDate.getTime() <= lastSampleDate.getTime() ) {
			switch(bottomTabBar.currentIndex) {
			case 0:
				dataIndex = Math.floor((lastSampleDate.getTime()-periodStartDate.getTime())/86400000 /*1000*60*60*24*/ );
				break;
			case 1:
				dataIndex = Math.floor((lastSampleDate.getTime()-periodStartDate.getTime())/604800000 /*1000*60*60*24*7*/);
				break;
			case 2:
				dataIndex = Math.floor(lastSampleDate.getMonth()-periodStartDate.getMonth()+
										 (12*(lastSampleDate.getFullYear()-periodStartDate.getFullYear())));
				break;
			}
		}

		return dataIndex;
	}

	function update() {
		if (p.loading)
			return;

		updateYourselfData();
		updateScreenState();
	}

	function updateYourselfData() {
		// update data from dataset if available
		if (!p.noData) {
			var data = app.benchmarkData[p.dataMode][p.dataPeriod];
			if(data) {
				p.lastSampleTime = data["lastSampleT"]*1000;
				p.dataIndex = calculateDataIndex(p.lastSampleTime);

				if (p.dataIndex != -1) {
					p.usage = p.dataIndex >= data["usages"].length ? "NaN" : data["usages"][p.dataIndex];
					p.lowUsage = p.dataIndex >= data["lowUsages"].length ? "NaN" : data["lowUsages"][p.dataIndex];
					p.averageUsage = p.dataIndex >= data["avgUsages"].length ? "NaN" : data["avgUsages"][p.dataIndex];
					p.percentile = p.dataIndex >= data["percentiles"].length ? "NaN" : data["percentiles"][p.dataIndex];
					p.compareToCount = p.dataIndex >= data["compareToCount"].length ? "NaN" : data["compareToCount"][p.dataIndex];
				} else
					p.percentile = "NaN";
			} else {
				p.percentile = "NaN";
			}
		}
	}

	function updateScreenState() {
		if (p.noData) {
			p.hoursTillData = app.countHoursLeft(topLeftTabBarGroup.currentControlId);
			notEnoughDataProgressBar.setProgress(p.hoursTillData);
			state = "notEnoughData";
		} else if (p.percentile === "NaN" || p.averageUsage === "NaN" || p.lowUsage === "NaN" || p.usage === "NaN" || p.compareToCount === "NaN") {
			state = "noResults";
		} else {
			p.averageUsage /= 1000;
			p.lowUsage /= 1000;
			p.usage /= 1000;

			state = yourFriendsCheckbox.selected ? "compareToFriends" : "compareToAverage";
			// Update yourself balloon must happen prior to updateFriends() in order to get label placement on balloons right
			benchmarkBar.setYourselfBalloon(getFormatedValue(p.usage), app.getBarPercentile(p.percentile));

			if (yourFriendsCheckbox.selected) {
				updateFriends();
			} else {
				// Update the benchmarkSummary
				var percentile = parseInt(p.percentile);
				benchmarkSummary.setLabel(app.determineSummaryText(percentile), benchmarkBar.currentBigBalloonColor);
			}
		}
	}

	function getFormatedValue(value) {
		var retVal = "";
		if (benchmarkBar.state !== "FRIENDS" && value && value !== "") {
			value = parseFloat(value);
			if (topLeftTabBarGroup.currentControlId >= 0) {
				retVal = i18n.number(value, 1, i18n.omit_trail_zeros) + " " + p.units[topLeftTabBarGroup.currentControlId];
			}
		}
		return retVal;
	}

	function updateFriends() {
		var friends = [];

		var missingFriends = 0;
		var ownPercentile = app.getBarPercentile(p.percentile);
		var amMostEconomical = true;
		var amLeastEconomical = true;

		for (var i = 0; i < app.benchmarkFriends.length; ++i) {
			// Update friends in benchmarkBar
			var friend = app.benchmarkFriends[i];
			if (friend.compareActive === "1") {
				var friendMissing = true;
				var compareFriend = {friend: friend, percentile: "NaN"};
				var typeData = friend.usage ? friend.usage[p.dataMode] : null;

				if (typeData) {
					var data = typeData[p.dataPeriod];
					if (data) {
						var friendLastSampleT = data.lastSampleT * 1000;
						var friendDataIndex = calculateDataIndex(friendLastSampleT);
						var percentiles = data.percentiles;
						compareFriend.percentile = (friendDataIndex < 0 || friendDataIndex >= percentiles.length || percentiles[friendDataIndex] === "NaN") ? "NaN" : app.getBarPercentile(percentiles[friendDataIndex]);

						if (compareFriend.percentile !== "NaN") {
							friendMissing = false;
							if (amLeastEconomical && compareFriend.percentile > ownPercentile)
								amLeastEconomical = false;
							else  if (amMostEconomical && compareFriend.percentile < ownPercentile)
								amMostEconomical = false;
						}
					}
				}
				// add compareFriend only if he has the same agreement (gas / heat)
				if (!((p.dataMode === "gas" && friend.gasUser === "false") ||
					  (p.dataMode === "heat" && friend.heatUser === "false"))) {
					friends.push(compareFriend);
				}
				if (friendMissing && (p.dataMode == "elec" || p.dataMode == "gas" && friend.gasUser === "true" || p.dataMode == "heat" && friend.heatUser === "true"))
					missingFriends++;
			}
		}
		friends.sort(function (a, b) {return a.percentile - b.percentile;});
		//check the special case when there are 4 friends checked and all of them have the same percentiles - showing only one balloon with "Four friends" text
		if (friends.length > 3 &&
				parseInt(friends[0].percentile) === benchmarkBar.yourselfPercentile &&
				parseInt(friends[1].percentile) === benchmarkBar.yourselfPercentile &&
				parseInt(friends[2].percentile) === benchmarkBar.yourselfPercentile &&
				parseInt(friends[3].percentile) === benchmarkBar.yourselfPercentile) {
			benchmarkBar.displayFriendsSummarised(friends);
		} else {
			benchmarkBar.setFriends(friends);
		}
		if (friends.length > missingFriends){
			benchmarkSummary.setLabel(amLeastEconomical == amMostEconomical ? 0 : amLeastEconomical ? 1 : -1, colors.percentileColors[ownPercentile]);
		} else {
			benchmarkSummary.visible = false;
		}

		friendDataMissingItem.visible = missingFriends > 0;
		if (missingFriends) {
			var plural = missingFriends == 1 ? qsTr("isn't") : qsTr("aren't");
			friendDataMissingText.text = qsTr("The data of %1 of your friends %2 available").arg(missingFriends).arg(plural);
		}
	}

	screenTitle: qsTr("Benchmark");
	screenTitleIconUrl: "drawables/vergelijk_menu.svg"

	Component.onDestruction: {
		globals.productOptionsChanged.disconnect(setTopLeftTabs);
	}

	onShown: {
		p.loading = true;
		topLeftTabBarGroup.currentControlId = 0;
		bottomTabBar.currentIndex = 0;
		dateSelector.periodStart = dateSelector.periodMaximum;
		yourFriendsCheckbox.selected = false;
		if (args) {
			if (args.type) {
				var index = p.modes.indexOf(args.type);
				topLeftTabBarGroup.currentControlId = index != -1 ? index : 0;
			}

			if (args.period) {
				index = p.periods.indexOf(args.period);
				bottomTabBar.currentIndex = index != -1 ? index : 0;
			}

			if (args.date) {
				var newDate = new Date(args.date);
				dateSelector.periodStart = newDate.getTime() > dateSelector.periodMaximum.getTime() ? dateSelector.periodMaximum : newDate;
			}

			yourFriendsCheckbox.selected = args.showFriends === true ? true : false;
		}
		// make sure screen content is updated even though tabs haven't changed
		bottomTabBar.currentIndexChanged();
		topLeftTabBarGroup.currentControlIdChanged();

		if (feature.featBenchmarkFriendsEnabled()) {
			if (app.benchmarkFriends.length > 0) {
				friendsCheckboxItem.visible = true;
				addFriendsButton.visible = false;
			} else {
				friendsCheckboxItem.visible = false;
				addFriendsButton.visible = true;
			}
			addCustomTopRightButton(qsTr("Friend list"));
		} else {
			friendsCheckboxItem.visible = false;
			addFriendsButton.visible = false;
		}

		p.loading = false;
		update();
	}

	onCustomButtonClicked: {
		stage.openFullscreen(app.benchmarkFriendsScreenUrl, {showDefault:true});
	}

	ControlGroup {
		id: topLeftTabBarGroup
		exclusive: true

		onCurrentControlIdChanged: {
			p.dataMode = p.modes[topLeftTabBarGroup.currentControlId];
			benchmarkScreen.update();
		}
	}

	Flow {
		id: topLeftTabBar
		anchors {
			left: mainRect.left
			top: parent.top
			topMargin: designElements.vMargin20
		}
		spacing: Math.round(4 * verticalScaling)

		TopTabButton {
			id: powerTabButton
			text: qsTr("Electricity")
			controlGroupId: 0
			controlGroup: topLeftTabBarGroup
		}
		TopTabButton {
			id: gasTabButton
			text: qsTr("Gas")
			controlGroupId: 1
			controlGroup: topLeftTabBarGroup
		}
	}

	Text {
		id: excludingSolar
		visible: parseInt(globals.productOptions["solar"]) && (globals.solarInHcbConfig === 1) && powerTabButton.selected
		anchors {
			verticalCenter: topLeftTabBar.verticalCenter
			left: topLeftTabBar.right
			leftMargin: designElements.hMargin20
		}
		text: qsTr("(excluding solar)")
		color: colors.benchmarkSolarExcludedText
		font {
			family: qfont.italic.name
			pixelSize: qfont.bodyText
		}
	}

	Flow {
		id: topRightTabBar
		anchors {
			bottom: mainRect.top
			bottomMargin: colors.tabButtonUseExtension ? Math.round(4 * verticalScaling) : 0
			right: mainRect.right
		}
		spacing: Math.round(4 * verticalScaling)

		TopTabButton {
			id: usageTabButton
			text: topLeftTabBarGroup.currentControlId >= 0 ? p.units[topLeftTabBarGroup.currentControlId] : ""
			selected: true
		}
	}

	Item {
		id: friendsCheckboxItem

		width: Math.round(100 * horizontalScaling)

		anchors {
			right: topRightTabBar.left
			rightMargin: designElements.hMargin5
			bottom: mainRect.top
		}

		StandardCheckBox {
			id: yourFriendsCheckbox

			anchors {
				bottom: parent.bottom
				bottomMargin: Math.round(7 * verticalScaling)
				right: yourFriendsLabel.left
				rightMargin: Math.round(8 * horizontalScaling)
			}

			onSelectedChanged: benchmarkScreen.update()

			text: ""
			backgroundColor: colors.none
			width: Math.round(27 * horizontalScaling)
		}

		Text {
			id: yourFriendsLabel

			anchors {
				baseline: parent.baseline
				baselineOffset: Math.round(-20 * verticalScaling)
				right: parent.right
				rightMargin: designElements.hMargin10
			}

			font {
				family: qfont.regular.name
				pixelSize: qfont.metaText
			}

			text: qsTr("Your friends")
		}
	}

	StandardButton {
		id: addFriendsButton

		text: qsTr("Add friends")
		iconSource: "drawables/LittleBlueBubble.svg"

		anchors {
			right: topRightTabBar.left
			rightMargin: designElements.hMargin5
			bottom: mainRect.top
			bottomMargin: designElements.vMargin6
		}

		onClicked: {
			stage.openFullscreen(app.benchmarkFriendsScreenUrl, {categoryUrl: Qt.resolvedUrl(app.addFriendFrameUrl)});
		}
	}

	Rectangle {
		id: mainRect
		anchors {
			top: topLeftTabBar.bottom
			topMargin: colors.tabButtonUseExtension ? Math.round(4 * verticalScaling) : 0
			bottom: bottomTabBar.top
			bottomMargin: anchors.topMargin
			left: parent.left
			right: parent.right
			leftMargin: Math.round(16 * horizontalScaling)
			rightMargin: anchors.leftMargin
		}
		color: colors.benchmarkMainRectBg

		BenchmarkSummaryLabel {
			id: benchmarkSummary

			anchors {
				left: mainRect.left
				leftMargin: Math.round(28 * verticalScaling)
				right: profileButton.left
				rightMargin: designElements.hMargin10
				verticalCenter: profileButton.verticalCenter
			}
		}

		StandardButton {
			id: profileButton
			text: qsTr("Your profile")
			iconSource: "drawables/TinyBlueDude.svg"

			anchors {
				right: parent.right
				rightMargin: designElements.hMargin10
				top:parent.top
				topMargin: Math.round(12 * verticalScaling)
			}

			leftClickMargin: designElements.hMargin5
			onClicked: {
				stage.openFullscreen(app.profileOverviewScreenUrl);
			}
		}

		IconButton {
			visible: yourFriendsCheckbox.selected
			iconSource: "qrc:/images/info.svg"

			anchors {
				right: profileButton.left
				rightMargin: designElements.hMargin10
				verticalCenter: profileButton.verticalCenter
			}

			rightClickMargin: designElements.hMargin5
			onClicked: {
				qdialog.showDialog(qdialog.SizeLarge, qsTr("Compare to friends"), p.friendsPopupSource);
			}
		}

		BenchmarkBar {
			id: benchmarkBar

			anchors {
				bottom: parent.bottom
				bottomMargin: Math.round(84 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(63 * horizontalScaling)
			}

			onFriendClicked: {
				if (yourFriendsCheckbox.selected) {
					var friendsToShow = [];

					for (var i = 0; i < friends.length; i++) {
						var friend = friends[i];
						if (friend.percentile !== "NaN") {
							var addFriend = app.getFriendData(friend.friend.commonname);
							addFriend.percentile = friend.percentile;
							friendsToShow.push(addFriend);
						}
					}

					if (friendsToShow.length) {
						qdialog.showDialog(qdialog.SizeLarge, qsTr("Your friends"), p.friendsDataPopupUrl);
						qdialog.context.dynamicContent.populate(friendsToShow);
					}
				}
			}
		}

		Item {
			id: friendDataMissingItem
			width: childrenRect.width
			height: childrenRect.height
			visible: false

			anchors {
				bottom: parent.bottom
				bottomMargin: Math.round(28 * verticalScaling)
				horizontalCenter: parent.horizontalCenter
			}

			function clicked() {
				var friends = benchmarkBar.friends;
				var unavailableFriends = [];

				for (var i = 0; i < friends.length; i++) {
					var friend = friends[i];
					if (friend.friend.compareActive === "1" && friend.percentile === "NaN" &&
							(p.dataMode == "elec" || p.dataMode == "gas" && friend.friend.gasUser === "true" || p.dataMode == "heat" && friend.friend.heatUser === "true")) {
						unavailableFriends.push(friend.friend.name);
					}
				}

				var unavailableFriendString = i18n.arrayToSentence(unavailableFriends, "b");
				qdialog.showDialog(qdialog.SizeMedium, qsTr("unavailable data"), qsTr("The data of %1 cannot be retrieved.").arg(unavailableFriendString));
			}

			IconButton {
				id: friendDataMissingButton
				iconSource: "drawables/exclamation.svg"
				width: Math.round(30 * horizontalScaling)
				height: Math.round(30 * verticalScaling)
				onClicked: friendDataMissingItem.clicked()
			}

			Text {
				id: friendDataMissingText

				anchors {
					left: friendDataMissingButton.right
					leftMargin: designElements.hMargin10
					verticalCenter: friendDataMissingButton.verticalCenter
				}

				color: colors.benchmarkBottomTitle
				font {
					family: qfont.italic.name
					pixelSize: 15
				}

				MouseArea {
					anchors.fill: parent
					onClicked: friendDataMissingItem.clicked()
				}
			}
		}

		Item {
			id: savingUsersTextfield

			anchors {
				bottom: parent.bottom
				bottomMargin: Math.round(28 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(63 * horizontalScaling)
			}

			Text {
				id: savingUsersTitle
				anchors {
					baseline: savingUsersValue.baseline
					baselineOffset: Math.round(-21 * verticalScaling)
					left: parent.left
				}

				text: qsTr("Saving Toon-Users")

				color: colors.benchmarkBottomTitle

				font {
					family: qfont.light.name
					pixelSize: qfont.metaText
				}
			}

			Text {
				id: savingUsersValue
				anchors {
					baseline: parent.bottom
					left: parent.left
				}

				text: qsTr("averaged at %1").arg(getFormatedValue(p.lowUsage))

				color: colors.benchmarkBottomValue

				font {
					family: qfont.regular.name
					pixelSize: qfont.metaText
				}
			}
		}

		Item {
			id: comparableUsersTextfield

			anchors {
				bottom: savingUsersTextfield.bottom
				left: savingUsersTextfield.left
				leftMargin: Math.round(226 * horizontalScaling)
			}

			IconButton {
				id: comparableUsageInfoButton

				width: Math.round(30 * horizontalScaling)
				height: Math.round(30 * verticalScaling)
				anchors {
					bottom: parent.bottom
					left: parent.left
				}

				iconSource: "qrc:/images/info.svg"

				onClicked: {
					var dialogContent = parseInt(globals.productOptions["solar"]) && (globals.solarInHcbConfig === 1) && powerTabButton.selected ? qsTr("benchmark_comparableUsers_popup_body_solarExcluded") : qsTr("benchmark_comparableUsers_popup_body");
					qdialog.showDialog(qdialog.SizeLarge, qsTr("benchmark_comparableUsers_popup_title"), dialogContent
									   .arg(comparableUsersTextfield.enabled?qsTr("benchmark_comparableUsers_popup_compareCount").arg(p.compareToCount):""));
					var popup = qdialog.context
				}
			}

			Text {
				id: comparableUsersTitle
				anchors {
					baseline: comparableUsersValue.baseline
					baselineOffset: Math.round(-21 * verticalScaling)
					left: comparableUsageInfoButton.right
					leftMargin: Math.round(8 * horizontalScaling)
				}

				text: qsTr("Comparable Toon-Users")

				color: colors.benchmarkBottomTitle

				font {
					family: qfont.light.name
					pixelSize: qfont.metaText
				}
			}

			Text {
				id: comparableUsersValue
				anchors {
					baseline: parent.bottom
					left: comparableUsageInfoButton.right
					leftMargin: Math.round(8 * horizontalScaling)
				}

				text: qsTr("averaged at %1").arg(getFormatedValue(p.averageUsage))

				color: colors.benchmarkBottomValue

				font {
					family: qfont.regular.name
					pixelSize: qfont.metaText
				}
			}
		}

		Item {
			id: notEnoughDataContent

			anchors.fill: parent
			visible: false

			Text {
				id: notEnoughDataUpperText
				anchors {
					baseline: parent.top
					baselineOffset: Math.round(100 * verticalScaling)
					left: parent.left
					leftMargin: Math.round(63 * horizontalScaling)
					right: parent.right
					rightMargin: anchors.leftMargin
				}
				color: colors.benchmarkBottomTitle
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				text: qsTr("not_enough_data_upper_text")
				wrapMode: Text.WordWrap
			}

			Text {
				id: notEnoughDataLowerText
				anchors {
					top: notEnoughDataUpperText.bottom
					topMargin: designElements.vMargin20
					left: notEnoughDataUpperText.left
					right: notEnoughDataUpperText.right
				}
				color: colors.benchmarkBottomTitle
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				text: qsTr("not_enough_data_lower_text")
				wrapMode: Text.WordWrap
			}

			NotEnoughDataProgressBar {
				id: notEnoughDataProgressBar
				anchors {
					bottom: notEnoughDataHoursLeftText.top
					bottomMargin: designElements.vMargin10
					horizontalCenter: parent.horizontalCenter
				}
			}

			Text {
				id: notEnoughDataHoursLeftText
				anchors {
					baseline: parent.bottom
					baselineOffset: Math.round(-30 * verticalScaling)
					horizontalCenter: parent.horizontalCenter
				}
				color: colors.benchmarkBottomTitle
				font {
					family: qfont.regular.name
					pixelSize: qfont.metaText
				}
				text: qsTr("not_enough_data_hours_left_text").arg(p.hoursTillData)
			}

		}
	}

	BottomTabBar {
		id: bottomTabBar
		currentIndex: 0
		anchors {
			left: mainRect.left
			bottom: parent.bottom
		}

		onCurrentIndexChanged: {
			p.dataPeriod = p.periods[currentIndex];
			setDateSelectorMode(currentIndex);
			benchmarkScreen.update();
		}
	}

	Rectangle {
		id: dateSelectorBackground
		width: dateSelector.width
		height: dateSelector.height
		anchors {
			top: mainRect.bottom
			right: mainRect.right
		}
		color: colors.benchmarkDateRectBg

		DateSelector {
			id: dateSelector
			onPeriodChanged: benchmarkScreen.update();

			states: [
				State {
					when: p.dataPeriod === "week"
					PropertyChanges { target: dateSelector; width: Math.round(280 * horizontalScaling) }
				}
			]
		}
	}

	state: "compareToAverage"
	states: [
		State {
			name: "compareToAverage"
			PropertyChanges { target: comparableUsersTextfield; visible:true; }
			PropertyChanges { target: savingUsersTextfield; visible:true; }
			PropertyChanges { target: dateSelector; enabled:true; }
			PropertyChanges { target: benchmarkBar; state: "YOURSELF"; }
			PropertyChanges { target: benchmarkSummary; state: "YOURSELF"; }
		},
		State {
			name: "compareToFriends"
			PropertyChanges { target: comparableUsersTextfield; visible:false; }
			PropertyChanges { target: savingUsersTextfield; visible:false; }
			PropertyChanges { target: friendDataMissingItem; visible:true; }
			PropertyChanges { target: dateSelector; enabled:true; }
			PropertyChanges { target: benchmarkBar; state: "FRIENDS"; }
			PropertyChanges { target: benchmarkSummary; state: "FRIENDS"; }
		},
		State {
			name: "noResults"
			PropertyChanges { target: comparableUsersTextfield; visible:false; }
			PropertyChanges { target: savingUsersTextfield; visible:false; }
			PropertyChanges { target: dateSelector; enabled:true; }
			PropertyChanges { target: benchmarkBar; state: "NORESULT"; }
			PropertyChanges { target: benchmarkSummary; state: "NORESULT"; visible: true }
		},
		State {
			name: "notEnoughData"
			PropertyChanges { target: comparableUsersTextfield; visible:false; }
			PropertyChanges { target: savingUsersTextfield; visible:false; }
			PropertyChanges { target: dateSelector; enabled:false; }
			PropertyChanges { target: benchmarkBar; visible: false; }
			PropertyChanges { target: notEnoughDataContent; visible: true; }
			PropertyChanges { target: benchmarkSummary; state: "NOTENOUGH"; }
		}
	]
}
