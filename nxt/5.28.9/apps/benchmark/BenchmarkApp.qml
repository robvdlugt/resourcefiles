import QtQuick 2.1
import BxtClient 1.0

import qb.components 1.0
import qb.base 1.0

App {
	id: benchmarkApp

	property BxtDatasetHandler tst_benchmarkInfoDsHandler: benchmarkInfoDsHandler
	property BxtDatasetHandler tst_benchmarkDataDsHandler: benchmarkDataDsHandler
	property BxtDatasetHandler tst_benchmarkFriendsDsHandler: benchmarkFriendsDsHandler

	property url profileMenuUrl: "drawables/profile_menu.svg"
	property MenuItem profileMenu

	property url benchmarkMenuUrl: "drawables/vergelijk_menu.svg"
	property MenuItem benchmarkMenu

	property url benchmarkWelcomeScreenUrl: "BenchmarkWelcomeScreen.qml"

	property url privacyAgreementScreenUrl: "PrivacyAgreementScreen.qml"
	property url privacyAgreementRejectedScreenUrl: "PrivacyAgreementRejectedScreen.qml"
	property url profilePolicyScreenUrl: "ProfilePolicyScreen.qml"

	property url benchmarkScreenUrl: "BenchmarkScreen.qml"
	property url benchmarkFriendsScreenUrl: "BenchmarkFriendsScreen.qml"

	property url friendsFrameUrl: "FriendsFrame.qml"
	property url addFriendFrameUrl: "AddFriendFrame.qml"
	property url invitationsFrameUrl: "InvitationsFrame.qml"

	property url profileWelcomeScreenUrl: "ProfileWelcomeScreen.qml"
	property url profileOverviewScreenUrl: "ProfileOverviewScreen.qml"
	property url wizardScreenUrl: "WizardScreen.qml"

	property url houseTypeScreenUrl: "HouseTypeScreen.qml"
	property url constructionPeriodScreenUrl: "ConstructionPeriodScreen.qml"
	property url surfaceAreaScreenUrl: "SurfaceAreaScreen.qml"
	property url familySizeScreenUrl: "FamilySizeScreen.qml"

	property url houseTypeFrameUrl: "HouseTypeFrame.qml"
	property url apartmentOptionsFrameUrl: "ApartmentOptionsFrame.qml"
	property url constructionPeriodFrameUrl: "ConstructionPeriodFrame.qml"
	property url surfaceAreaFrameUrl: "SurfaceAreaFrame.qml"
	property url familySizeFrameUrl: "FamilySizeFrame.qml"
	property url nameFrameUrl: "NameFrame.qml"
	property url profileOverviewFrameUrl: "ProfileOverviewFrame.qml"

	property url benchmarkPowerTileUrl: "BenchmarkPowerTile.qml"
	property url benchmarkPowerTileIcon: "drawables/TileBenchmarkKwh.svg"
	property url benchmarkFriendsPowerTileUrl: "BenchmarkFriendsPowerTile.qml"
	property url benchmarkFriendsPowerTileIcon: "drawables/TileFriendsIcon.svg"
	property url benchmarkGasTileUrl: "BenchmarkGasTile.qml"
	property url benchmarkGasTileIcon: "drawables/TileBenchmarkGas.svg"
	property url benchmarkFriendsGasTileUrl: "BenchmarkFriendsGasTile.qml"
	property url benchmarkFriendsGasTileIcon: "drawables/TileFriendsIcon.svg"

	property int _FS_INITIAL: 0
	property int _FS_PENDING: 1
	property int _FS_REVOKED: 2
	property int _FS_DENIED: 3
	property int _FS_ACCEPTED: 4
	property int _FS_ENDED: 5

	property variant benchmarkInfo : {
		'permission': "-",
		'wizardDone' : false,
		'gotSJV' : false
	}

	property variant profileInfo : {
		'homeType' : "-",
		'homeTypeAlt' : "-",
		'homeSize' : "-",
		'homeBuildPeriod' : "-",
		'familyType' : "-",
		'screenName' : "-",
		'lastChange' : "-"
	}

	property variant houseTypeScreenData : [
		{
			'iconUnselected' : "drawables/HouseOption01.svg",
			'iconSelected' : "drawables/HouseOption01Selected.svg",
			'name' : qsTr("Apartment")
		},
		{
			'iconUnselected' : "drawables/HouseOption02.svg",
			'iconSelected' : "drawables/HouseOption02Selected.svg",
			'name' : qsTr("Detached")
		},
		{
			'iconUnselected' : "drawables/HouseOption03.svg",
			'iconSelected' : "drawables/HouseOption03Selected.svg",
			'name' : qsTr("Semi-detached")
		},
		{
			'iconUnselected' : "drawables/HouseOption04.svg",
			'iconSelected' : "drawables/HouseOption04Selected.svg",
			'name' : qsTr("Corner house")
		},
		{
			'iconUnselected' : "drawables/HouseOption05.svg",
			'iconSelected' : "drawables/HouseOption05Selected.svg",
			'name' : qsTr("Row house")
		},
		{
			'iconUnselected' : "drawables/HouseOption06.svg",
			'iconSelected' : "drawables/HouseOption06Selected.svg",
			'name' : qsTr("Other")
		}
	]

	property variant familyTypeScreenData : [
		{
			'iconUnselected' : "drawables/FamilyOption01.svg",
			'iconSelected' : "drawables/FamilyOption01Selected.svg",
			'name' : qsTr("Single")
		},
		{
			'iconUnselected' : "drawables/FamilyOption02.svg",
			'iconSelected' : "drawables/FamilyOption02Selected.svg",
			'name' : qsTr("Living together")
		},
		{
			'iconUnselected' : "drawables/FamilyOption03.svg",
			'iconSelected' : "drawables/FamilyOption03Selected.svg",
			'name' : qsTr("Small family")
		},
		{
			'iconUnselected' : "drawables/FamilyOption04.svg",
			'iconSelected' : "drawables/FamilyOption04Selected.svg",
			'name' : qsTr("Average family")
		},
		{
			'iconUnselected' : "drawables/FamilyOption05.svg",
			'iconSelected' : "drawables/FamilyOption05Selected.svg",
			'name' : qsTr("Big family")
		}
	]

	property variant constructionPeriodScreenData : [
		qsTr("Before 1946"),
		qsTr("1946 to 1965"),
		qsTr("1966 to 1975"),
		qsTr("1976 to 1988"),
		qsTr("1989 to 2000"),
		qsTr("After 2000"),
		qsTr("I dont know")
	]

	signal newDataAvailable()

	property variant benchmarkData: {
		'haveElecMidnight':false,
		'haveHeatMidnight':false,
		'haveGasMidnight':false
	}
	property bool benchmarkDataRead: false

	property variant billingInfo: ({})

	property variant benchmarkFriends: []

	property int invitations: 0
	property int comparableFriendsCount: 0
	property int invitationSuccess: -1
	property string invitationFaultCode: ""
	/// flag if new profile wizard was opened from benchmark menu (and not from profile menu) - if true, open benchmark after the wizard is done. Navigate home otherwise
	property bool openBenchmarkAfterWizard: false
	signal invitationResponse();

	QtObject {
		id: p
		property string pwrusageUuid
		property variant registeredTiles: []
		property bool enableSME: globals.productOptions["SME"] === "1"
	}

	function init() {
		registry.registerWidget("menuItem", null, benchmarkApp, "profileMenu", {objectName: "profileMenuItem", label: qsTr("Profile"), image: profileMenuUrl, weight: 80});
		registry.registerWidget("menuItem", null, benchmarkApp, "benchmarkMenu", {objectName: "benchmarkMenuItem", label: qsTr("Compare"), image: benchmarkMenuUrl, weight: 70, args: {showDefaults:true} } );
		registry.registerWidget("screen", benchmarkWelcomeScreenUrl, benchmarkApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", privacyAgreementScreenUrl, benchmarkApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", privacyAgreementRejectedScreenUrl, benchmarkApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", profilePolicyScreenUrl, benchmarkApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", profileWelcomeScreenUrl, benchmarkApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", wizardScreenUrl, benchmarkApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", benchmarkScreenUrl, benchmarkApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", houseTypeScreenUrl, benchmarkApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", constructionPeriodScreenUrl, benchmarkApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", surfaceAreaScreenUrl, benchmarkApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", familySizeScreenUrl, benchmarkApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", profileOverviewScreenUrl, benchmarkApp, null, {lazyLoadScreen: true});
		if (feature.featBenchmarkFriendsEnabled()) {
			registry.registerWidget("screen", benchmarkFriendsScreenUrl, benchmarkApp, null, {lazyLoadScreen: true});
			registry.registerWidget("benchmarkFriendsFrame", friendsFrameUrl, benchmarkApp, null, {categoryName: qsTr("Friends"), categoryWeight: 100});
			registry.registerWidget("benchmarkFriendsFrame", addFriendFrameUrl, benchmarkApp, null, {categoryName: qsTr("Add Friends"), categoryWeight: 300});
			registry.registerWidget("benchmarkFriendsFrame", invitationsFrameUrl, benchmarkApp, null, {categoryName: qsTr("Invitations"), categoryWeight: 200, bulletNumProperty: "invitations"});
		}
		if (feature.featSMEEnabled()) {
			p.enableSMEChanged.connect(smeOptionChanged);
			smeOptionChanged();
		} else {
			registerTiles(true);
		}
	}

	function registerTiles(register) {
		if (register === false) {
			p.registeredTiles.forEach(function(tileUid) {
				registry.deregisterWidget(tileUid);
			});
			p.registeredTiles = [];
		} else if(register === true) {
			var tmpRegisteredTiles = [];
			if (globals.productOptions["electricity"] === "1") {
				tmpRegisteredTiles.push(registry.registerWidget("tile", benchmarkPowerTileUrl, benchmarkApp, null, {thumbLabel: qsTr("Electricity"), thumbIcon: benchmarkPowerTileIcon, thumbCategory: "benchmark", thumbWeight: 20, baseTileWeight: 50, baseTileSolarWeight: 60}));
				if (feature.featBenchmarkFriendsEnabled())
					tmpRegisteredTiles.push(registry.registerWidget("tile", benchmarkFriendsPowerTileUrl, benchmarkApp, null, {thumbLabel: qsTr("Electricity"), thumbIcon: benchmarkFriendsPowerTileIcon, thumbCategory: "benchmarkFriends", thumbWeight: 10, thumbIconVAlignment: "center"}));
			}
			if (globals.productOptions["gas"] === "1") {
				tmpRegisteredTiles.push(registry.registerWidget("tile", benchmarkGasTileUrl, benchmarkApp, null, {thumbLabel: qsTr("Gas"), thumbIcon: benchmarkGasTileIcon, thumbCategory: "benchmark", thumbWeight: 40, thumbIconVAlignment: "center"}));
				if (feature.featBenchmarkFriendsEnabled())
					tmpRegisteredTiles.push(registry.registerWidget("tile", benchmarkFriendsGasTileUrl, benchmarkApp, null, {thumbLabel: qsTr("Gas"), thumbIcon: benchmarkFriendsGasTileIcon, thumbCategory: "benchmarkFriends", thumbWeight: 20, thumbIconVAlignment: "center"}));
			}
			p.registeredTiles = tmpRegisteredTiles;
		}
	}

	function parseBenchmarkInfo(node) {
		var tempBenchmarkInfo = benchmarkInfo;
		tempBenchmarkInfo.permission = node.getChild("permission").text;
		tempBenchmarkInfo.wizardDone = node.getChildText("wizardDone") === "true";

		// If privacy statement was already accepted but wizard was not done reset the the 'privacy agreement' flag.
		if (parseInt(tempBenchmarkInfo.permission) === 3 && tempBenchmarkInfo.wizardDone === false) {
			tempBenchmarkInfo.permission = 0;
			var setPermissionMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrusageUuid, "Benchmark", "SetPermission");

			setPermissionMessage.addArgument("privacyUuid", "32d2b2b0-a468-11e3-a5e2-0800200c9a66");
			setPermissionMessage.addArgument("permission", "0");
			bxtClient.sendMsg(setPermissionMessage);
		}

		tempBenchmarkInfo.gotSJV = node.getChildText("gotSJV") === "true";
		benchmarkInfo = tempBenchmarkInfo;

		var tempProfileInfo = profileInfo;
		tempProfileInfo.homeType = node.getChildText("homeType");
		tempProfileInfo.homeTypeAlt = node.getChildText("homeTypeAlt");
		tempProfileInfo.homeSize = node.getChildText("homeSize");
		tempProfileInfo.homeBuildPeriod = node.getChildText("homeBuildPeriod");
		tempProfileInfo.familyType = node.getChildText("familyType");
		tempProfileInfo.screenName = node.getChildText("screenName");
		tempProfileInfo.lastChange = node.getChildText("setTime");
		profileInfo = tempProfileInfo;

		// Temporary logging
		console.log("benchmarkInfo");
		console.log("permission: " + benchmarkInfo.permission);
		console.log("wizardDone: " + benchmarkInfo.wizardDone);
		console.log("gotSJV: " + benchmarkInfo.gotSJV);
		console.log("profileInfo");
		console.log("homeType: " + profileInfo.homeType);
		console.log("homeTypeAlt: " + profileInfo.homeTypeAlt);
		console.log("homeSize: " + profileInfo.homeSize);
		console.log("homeBuildPeriod: " + profileInfo.homeBuildPeriod);
		console.log("familyType: " + profileInfo.familyType);
		console.log("screenName: " + profileInfo.screenName);
		console.log("lastChange: " + profileInfo.lastChange)

		if (!benchmarkInfo.wizardDone) {
			profileMenu.screenUrl = profileWelcomeScreenUrl;
			benchmarkMenu.screenUrl =  benchmarkWelcomeScreenUrl;
		} else {
			profileMenu.screenUrl = profileOverviewScreenUrl;
			benchmarkMenu.screenUrl = benchmarkScreenUrl;
		}
		newDataAvailable();
		initVarDone(1);
	}

	function parseBenchmarkData(node) {
		var tempData = {};
		var usageType, period;

		var tempNode = node.getChild("dataValues");
		while (tempNode) {
			usageType = tempNode.getChildText("usageType");
			period = tempNode.getChildText("period");
			if (!tempData[usageType]) {
				tempData[usageType] = {};
			}
			tempData[usageType][period] = {};
			tempData[usageType][period]["lastSampleT"] = tempNode.getChildText("lastSampleT");
			tempData[usageType][period]["percentiles"] = tempNode.getChildText("percentiles").split(":");
			tempData[usageType][period]["avgUsages"]= tempNode.getChildText("avgUsages").split(":");
			tempData[usageType][period]["usages"] = tempNode.getChildText("usages").split(":");
			tempData[usageType][period]["lowUsages"] = tempNode.getChildText("lowUsages").split(":");
			tempData[usageType][period]["compareToCount"] = tempNode.getChildText("compareToCount").split(":");

			tempNode = tempNode.next;
		}

		tempData.haveElecMidnight = (node.getChildText("haveElecMidnight") === "true");
		tempData.haveHeatMidnight = (node.getChildText("haveHeatMidnight") === "true");
		tempData.haveGasMidnight = (node.getChildText("haveGasMidnight") === "true");

		benchmarkData = tempData;
		benchmarkDataRead = true;
		newDataAvailable();
		initVarDone(0);
	}

	function parseBenchmarkFriends(node) {
		var tempBenchmarkFriends = [];
		var tempFriendData, tempNodeParam, usageType, period, tempValues;
		var tempComparableFriendsCount = 0, tempInvitations = 0;

		var tempNode = node.getChild("friend");
		while (tempNode) {
			tempFriendData = {};
			// create friend data using every data available
			tempNodeParam = tempNode.getChild("commonname");
			while (tempNodeParam) {
				if (tempNodeParam.name === "dataValues") {
					tempFriendData["usage"] = {};
					tempValues = tempNodeParam;
					while (tempValues) {
						usageType = tempValues.getChildText("usageType");
						period = tempValues.getChildText("period");
						if (!tempFriendData["usage"][usageType]) {
							tempFriendData["usage"][usageType] = {};
						}
						tempFriendData["usage"][usageType][period] = {};
						tempFriendData["usage"][usageType][period]["lastSampleT"] = tempValues.getChildText("lastSampleT");
						tempFriendData["usage"][usageType][period]["percentiles"] =	tempValues.getChildText("percentiles").split(":");

						tempValues = tempValues.next;
					}
				} else {
					tempFriendData[tempNodeParam.name] = tempNodeParam.text;
				}
				tempNodeParam = tempNodeParam.sibling;
			}

			if (tempFriendData.compareActive === "1")
				tempComparableFriendsCount++;
			else if (tempFriendData.accepted === "0" && parseInt(tempFriendData.friendState) === _FS_PENDING)
				tempInvitations++;

			tempBenchmarkFriends.push(tempFriendData);
			tempNode = tempNode.next;
		}

		invitations = tempInvitations;
		benchmarkFriends = tempBenchmarkFriends;
		comparableFriendsCount = tempComparableFriendsCount;
		newDataAvailable();
		initVarDone(2);
	}

	/*
		returns friends that have paramether 'param' equal to 'val'
	*/
	function  getFriendsByParam(param, val) {
		return benchmarkFriends.filter(function(o){return o[param] === val;});
	}

	function getFriendData(commonname) {
		var friend = getFriendsByParam("commonname", commonname)[0];
		var retFriend = {};

		retFriend.name = friend.name;
		retFriend.commonname = commonname;
		retFriend.requestT = friend.requestT;
		retFriend.homeSize = friend.homeSize;

		if (typeof friend.homeType != 'undefined')
			retFriend.homeImage = houseTypeScreenData[friend.homeType].iconUnselected;

		if (typeof friend.homeBuildPeriod != 'undefined')
			retFriend.buildPeriodText = constructionPeriodScreenData[friend.homeBuildPeriod];

		if (typeof friend.familyType != 'undefined')
			retFriend.familyImage = familyTypeScreenData[friend.familyType - 1].iconUnselected;

		return retFriend;
	}

	function getFriendlistFriends(invitations) {
		var retArr = [];
		for (var i = 0; i < benchmarkFriends.length; i++) {
			var friend = benchmarkFriends[i];
			var friendState = parseInt(friend.friendState);
			if (friendState === _FS_DENIED || friendState === _FS_ENDED || friendState === _FS_REVOKED)
				continue;

			if ((invitations && friend.accepted === "1") || (!invitations && friend.accepted === "0"))
				continue;

			retArr.push(friend);
		}

		return retArr;
	}

	function hasValidCompareData(friend) {
		var usage = friend["usage"];
		if (usage) {
			var elecData = usage["elec"];
			if (elecData) {
				var dayData = elecData["day"];
				if (dayData) {
					var percentiles = dayData["percentiles"];
					if (percentiles) {
						var len = percentiles.length;
						for (var i = 0; i < len; i++)
						{
							if (percentiles[i] !== "NaN")
								return true;
						}
					}
				}
			}
		}
		return false;
	}

	function setPermission(accepted) {
		var tempBenchmarkInfo = benchmarkInfo;
		var setPermissionMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrusageUuid, "Benchmark", "SetPermission");

		setPermissionMessage.addArgument("privacyUuid", "32d2b2b0-a468-11e3-a5e2-0800200c9a66");
		if (accepted) {
			setPermissionMessage.addArgument("permission", "3");
			tempBenchmarkInfo.permission = "3";
		} else {
			setPermissionMessage.addArgument("permission", "4");
			tempBenchmarkInfo.permission = "4";
		}

		bxtClient.sendMsg(setPermissionMessage);
		benchmarkInfo = tempBenchmarkInfo;
	}

	function removeProfile() {
		var tempBenchmarkInfo = benchmarkInfo;
		var setPermissionMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrusageUuid, "Benchmark", "SetPermission");
		setPermissionMessage.addArgument("permission", "2");
		tempBenchmarkInfo.permission = "2";
		bxtClient.sendMsg(setPermissionMessage);
		benchmarkInfo = tempBenchmarkInfo;
	}

	function setProfileInfo(homeType, homeTypeAlt, homeSize, homeBuildPeriod, familyType) {
		console.debug(" homeType " + homeType + " homeTypeAlt " + homeTypeAlt + " homeSize " + homeSize + " homeBuildPeriod " + homeBuildPeriod + " familyType " + familyType);
		var tempProfileInfo = profileInfo;
		tempProfileInfo.homeType = homeType;
		tempProfileInfo.homeTypeAlt = homeTypeAlt;
		tempProfileInfo.homeSize = homeSize;
		tempProfileInfo.homeBuildPeriod = homeBuildPeriod;
		tempProfileInfo.familyType = familyType;
		profileInfo = tempProfileInfo;

		var setProfileInfoMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrusageUuid, "Benchmark", "SetProfileInfo");
		setProfileInfoMessage.addArgument("homeType", homeType);
		setProfileInfoMessage.addArgument("homeTypeAlt", homeTypeAlt);
		setProfileInfoMessage.addArgument("homeSize", homeSize);
		setProfileInfoMessage.addArgument("homeBuildPeriod", homeBuildPeriod);
		setProfileInfoMessage.addArgument("familyType", familyType);
		bxtClient.sendMsg(setProfileInfoMessage);
	}

	function setScreenName(name) {
		var tempProfileInfo = profileInfo;
		tempProfileInfo.screenName = name
		profileInfo = tempProfileInfo;

		var setScreenNameMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrusageUuid, "Benchmark", "SetScreenName");
		setScreenNameMessage.addArgument("name", name);
		bxtClient.sendMsg(setScreenNameMessage);
	}

	function enableBenchmark(homeType, homeTypeAlt, homeSize, homeBuildPeriod, familyType, screenName) {
		var tempProfileInfo = profileInfo;
		tempProfileInfo.permission = "3";
		tempProfileInfo.homeType = homeType;
		tempProfileInfo.homeTypeAlt = homeTypeAlt;
		tempProfileInfo.homeSize = homeSize;
		tempProfileInfo.homeBuildPeriod = homeBuildPeriod;
		tempProfileInfo.familyType = familyType;
		tempProfileInfo.screenName = screenName;
		profileInfo = tempProfileInfo;

		var enableBenchmarkMsg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrusageUuid, "Benchmark", "EnableBenchmark");
		enableBenchmarkMsg.addArgument("privacyUuid", "32d2b2b0-a468-11e3-a5e2-0800200c9a66");
		enableBenchmarkMsg.addArgument("permission", "3");
		enableBenchmarkMsg.addArgument("homeType", homeType);
		enableBenchmarkMsg.addArgument("homeTypeAlt", homeTypeAlt);
		enableBenchmarkMsg.addArgument("homeSize", homeSize);
		enableBenchmarkMsg.addArgument("homeBuildPeriod", homeBuildPeriod);
		enableBenchmarkMsg.addArgument("familyType", familyType);
		enableBenchmarkMsg.addArgument("name", screenName);
		bxtClient.sendMsg(enableBenchmarkMsg);
	}

	function setFriendCompareActive(commonname, compareActive) {
		var setFriendCompareActiveMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrusageUuid, "Benchmark", "SetFriendCompareActive");
		setFriendCompareActiveMessage.addArgument("commonname", commonname);
		setFriendCompareActiveMessage.addArgument("compareActive", compareActive);
		bxtClient.doAsyncBxtRequest(setFriendCompareActiveMessage, setFriendCompareActiveCallback, 2000);
	}

	function acceptInvite(commonname) {
		var acceptMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrusageUuid, "Benchmark", "AcceptFriend");
		acceptMessage.addArgument("commonname", commonname);
		bxtClient.sendMsg(acceptMessage);
	}

	function removeFriend(commonname) {
		var removeMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrusageUuid, "Benchmark", "RemoveFriend");
		removeMessage.addArgument("commonname", commonname);
		bxtClient.sendMsg(removeMessage);
	}	

	function setFriendInvitation(commonname, zipCode) {
		if (commonname && zipCode){
			var addFriendMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrusageUuid, "Benchmark", "AddFriend");
			addFriendMessage.addArgument("commonname", commonname);
			addFriendMessage.addArgument("zipcode", zipCode);
			addFriendMessage.addArgument("nameForFriend", commonname);
			bxtClient.sendMsg(addFriendMessage);
		}
	}

	function getLastProfileEditDate() {
		var profileEditDate = new Date(parseInt(profileInfo.lastChange) * 1000);
		return profileEditDate;
	}

	function countHoursLeft(usageType) {
		var date = new Date();
		var hours = 4 - date.getHours();

		if (hours < 0)
			hours += 24;

		switch (usageType) {
		case 0:
			if (!benchmarkData.haveElecMidnight)
				hours += 24;
			break;

		case 1:
			if (globals.productOptions['district_heating'] === "1") {
				if (!benchmarkData.haveHeatMidnight)
					hours += 24;
			} else {
				if (!benchmarkData.haveGasMidnight)
					hours += 24;
			}
			break;
		}

		return hours;
	}

	function getBarPercentile(percentile) {
		return percentile === 100 ? 18 : Math.floor(percentile / 100 * 19);
	}

	function determineSummaryText (percentile) {
		if (percentile >= 48 && percentile <= 52) {
			return 0;
		} else if (percentile > 50) {
			return 1;
		} else if (percentile < 50) {
			return -1;
		}
	}

	function smeOptionChanged() {
		if (p.enableSME) {
			profileMenu.visible = false;
			benchmarkMenu.visible = false;
			registerTiles(false);
		} else {
			profileMenu.visible = true;
			benchmarkMenu.visible = true;
			registerTiles(true);
		}
	}

	// 0=data, 1=info, 2=friends
	initVarCount: 3

	BxtRequestCallback {
		id: setFriendCompareActiveCallback
		onMessageReceived: {
			if (message.getArgumentXml("success").text === "1") {
				var commonname = message.getArgument("commonname");
				var compareActive = message.getArgument("compareActive");

				var newBenchmarkFriends = benchmarkFriends;

				for (var i = 0; i < newBenchmarkFriends.length; i++){
					if (newBenchmarkFriends[i].commonname === commonname){
						newBenchmarkFriends[i].compareActive = compareActive;
						break;
					}
				}

				benchmarkFriends = newBenchmarkFriends;
				comparableFriendsCount = getFriendsByParam("compareActive","1").length;
				newDataAvailable();
			}
		}
	}

	BxtDiscoveryHandler {
		id: powerUsageDiscoHandler
		deviceType: "happ_pwrusage"

		onDiscoReceived: {
			p.pwrusageUuid = deviceUuid;
		}
	}

	BxtDatasetHandler {
		id: benchmarkInfoDsHandler
		dataset: "benchmarkInfo"

		discoHandler: powerUsageDiscoHandler
		onDatasetUpdate: parseBenchmarkInfo(update)
	}

	BxtDatasetHandler {
		id: benchmarkDataDsHandler
		dataset: "benchmarkData"

		discoHandler: powerUsageDiscoHandler
		onDatasetUpdate: parseBenchmarkData(update)
	}

	BxtDatasetHandler {
		id: benchmarkFriendsDsHandler
		dataset: "benchmarkFriends"

		discoHandler: powerUsageDiscoHandler
		onDatasetUpdate: parseBenchmarkFriends(update)
	}

	BxtResponseHandler {
		serviceId: "Benchmark"
		response: "AddFriendResponse"
		onResponseReceived: {
			invitationSuccess = parseInt(message.getArgument("success"));
			invitationFaultCode = message.getArgument("reason") ? message.getArgument("reason") : message.getArgument("code");
			invitationResponse();
		}
	}
}
