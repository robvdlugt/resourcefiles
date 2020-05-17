import QtQuick 2.1
import BxtClient 1.0

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0
import ScreenStateController 1.0

Screen {
	id: mainContent

	anchors.fill: parent

	property HomescreenApp app

	property int tilesCount: 0 // The number of non-empty tiles
	property int pagecount: 0
	property int currentPage: 0
	property int restorePage: -1
	property variant instantiatedTiles: ({})

	property url emptyTileUrl: "EmptyTile.qml"
	property url fourTilePageUrl: "FourTilePage.qml"
	property url sixTilePageUrl: "SixTilePage.qml"

	property int tilesPerPage: globals.heatingMode === "none" ? 6 : 4

	property string configMsgUuid

	property bool prominentLeft: screenStateController.prominentWidgetLeft

	QtObject {
		id: p
		property variant baseSetTiles: []
		property variant baseSetTilesSolar: []
		//this tile will be added when the solar is installed but the base set tile was changed (solar base set is not used)
		property variant tileToAddAtSolarInstall
		//0 - create base set tiles, 1 - base set tiles created (saved), 2 - base set (NOT solar) tiles changed,
		//3 - base set tiles SOLAR created (saved), 4 - base set SOLAR tiles changed, 5 - solar installed after base set changed - take and return tile added
		property int baseSetTilesStatus: 0
		property bool tileConfigLoaded: false
		property bool loadingBaseSet: false
		property bool solarInstalled: globals.productOptions["solar"] === "1" && globals.solarInHcbConfig === 1

		// for unit tests
		property alias ut_tileContainer: tileContainer

		onSolarInstalledChanged: {
			if (p.solarInstalled)
				canvas.appsDoneLoading.connect(createSolarBaseSetTiles);
		}

		function createSolarBaseSetTiles() {
			if (p.solarInstalled) {
				canvas.appsDoneLoading.disconnect(createSolarBaseSetTiles);

				if (p.baseSetTilesStatus == 1) {
					p.loadingBaseSet = true;
					//remove all tiles
					for (var page = tileContainer.children.length - 1; page >= 0 ; page--) {
						var pageContainer = tileContainer.children[page];
						for (var pos = 0; pos < pageContainer.children.length; pos++) {
							if (!pageContainer.children[pos].isEmptyTile) {
								removeTile(page, pos);
							}
						}
					}

					while (tileContainer.children.length > 1) {
						var page = tileContainer.children[0];
						page.visible = false;
						page.parent = null;
						page.destroy();
					}
					pagecount = 1;
					currentPage = 0;
					widgetNavBar.navigateBtn(currentPage);

					//add solar base set tile
					var baseTiles = p.baseSetTilesSolar;
					baseTiles.sort(function (a, b) {return a.baseTileWeight - b.baseTileWeight;})
					var tileIndex=0;
					var pageIndex=0;
					for ( var i=0; i<baseTiles.length; i++) {
						createTile(baseTiles[i].widgetInfo, pageIndex, tileIndex);

						if(tileIndex == tilesPerPage - 1) {
							tileIndex = 0;
							pageIndex++
						} else {
							tileIndex++;
						}
					}
					p.loadingBaseSet = false;
					saveBaseSetTilesStatus(3);
				} else if (p.baseSetTilesStatus == 2) {
					//add solar current generation tile as last tile
					if (p.tileToAddAtSolarInstall) {
						//first find the place (AC: Place a current generation tile on the last empty tile of the last page that contains tiles)
						var pageIndex = -1, tileIndex = -1;
						for (var page = tileContainer.children.length - 1; page >= 0 && pageIndex < 0; page--) {
							var pageContainer = tileContainer.children[page];
							for (var pos = pageContainer.children.length - 1; pos >= 0 && pageIndex < 0; pos--) {
								if (!pageContainer.children[pos].isEmptyTile) {
									pageIndex = page; tileIndex = pos;
									break;
								}
							}
						}
						tileIndex++;
						if (tileIndex >= tilesPerPage) {
							pageIndex++;
							tileIndex = 0;
						}
						createTile(p.tileToAddAtSolarInstall, pageIndex, tileIndex);
					}
					saveBaseSetTilesStatus(5);
				}
			}
		}
	}

	function wakeup() {}

	function sleep() {}

	function init(app) {
		registry.registerWidgetContainer("tile", mainContent);
		createPage();

		dependencyResolver.addDependencyTo("Homescreen.loadTileConfig", "Homescreen.uuidConfig");
		dependencyResolver.getDependantSignals("Homescreen.loadTileConfig").resolved.connect(loadTileConfig);
		// Load the tiles despite the unresolved dependencies
		dependencyResolver.setDependantTimeout("Homescreen.loadTileConfig", 20000).connect(loadTileConfig);
	}

	function createPage() {
		var tilePageUrl = tilesPerPage === 6 ? sixTilePageUrl : fourTilePageUrl;
		var newPage = util.loadComponent(tilePageUrl, tileContainer, {});

		if (newPage === null) {
			console.debug("Failed to create page!");
			return;
		}

		for (var i = 0; i < newPage.children.length; i++) {
			newPage.children[i].homeApp = app;
			newPage.children[i].page = pagecount;
			newPage.children[i].position = i;
		}

		pagecount = pagecount + 1;
	}

	function createTile(tileWidgetInfo, page, position, uuid) {
		var tile;
		var tileUrl = tileWidgetInfo.url;
		if (!tileWidgetInfo) tileWidgetInfo  = {context: null};
		var requestedPageContainer = tileContainer.children[page];
		var nextPageContainer = tileContainer.children[page + 1];

		// check if tile will be created on existing page
		if (requestedPageContainer === undefined) {
			console.log("ERROR | Homescreen | createTile() | Page does not exist!");
			return;
		}

		// create a new tile dynamically
		tile = util.loadComponent(tileWidgetInfo.url, requestedPageContainer, {app: tileWidgetInfo.context, widgetInfo: tileWidgetInfo, widgetArgs: tileWidgetInfo.args});
		if (!tile) {
			console.log("Failed instantiating tile from " + tileUrl);
			return;
		}
		console.log("Succeeded instantiating tile from " + tileUrl);

		// assign page number and position to the tile
		tile.page = page;
		tile.position = position;
		tile.homeApp = app;

		// update tile configuration
		updateTileConfig(tileUrl, tile, uuid);

		// swap tiles if neccesarry
		if (requestedPageContainer.children.length > position) {
			replaceNewTile(requestedPageContainer, position);
		}

		// if next page does not exist - create it
		if (!(requestedPageContainer.empty) && nextPageContainer === undefined) {
			createPage();
		}

		if (tile === null) {
			console.debug("Failed to create widget!");
			return;
		} else {

			if (tileWidgetInfo.context)
				tile.initWidget(tileWidgetInfo);
			else
				tile.app = app;
		}

		//this also handles removing of the tile - empty tile is created
		if (!p.loadingBaseSet && (p.baseSetTilesStatus == 1 || p.baseSetTilesStatus == 3)) {
			saveBaseSetTilesStatus(p.baseSetTilesStatus + 1);
		}

		tilesCount++;
		kpiTimer.restart();
	}

	function appendNewTile(tileWidgetInfo) {
		var emptyPos = getFirstEmptyTilePos();
		createTile(tileWidgetInfo, emptyPos[0], emptyPos[1]);
	}

	function navigatePage(page) {
		console.log("New page #"+ page);
		var lastCurrentPage = currentPage;
		currentPage = page;
		var endPage = pagecount;
		endPage -= 1;
		var removePage = false;

		var lastPageContainer = tileContainer.children[lastCurrentPage];

		// if previous page is not a last page and is empty - remove it
		if (lastCurrentPage !== endPage && lastPageContainer.empty) {
			lastPageContainer.visible = false;
			lastPageContainer.parent = null;
			lastPageContainer.destroy();
			pagecount--;
			kpiTimer.restart();
			removePage = true;
			for (var i = lastCurrentPage; i < endPage; ++i) {
				for (var j = 0; j < tilesPerPage; ++j) {
					tileContainer.children[i].children[j].page -= 1;
				}
			}
		}

		if (currentPage === endPage && removePage) {
			currentPage = pagecount - 1;
			widgetNavBar.navigateBtn(currentPage);
		} else if (lastCurrentPage < currentPage && removePage) {
			currentPage -= 1;
			widgetNavBar.navigateBtn(currentPage);
		} else {
			tileContainerParent.contentX = currentPage * (leftPanel.width + tileContainer.spacing);
			var currentPageContainer = tileContainer.children[currentPage];

			for (i = 0; i < currentPageContainer.children.length; i++) {
				currentPageContainer.children[i].pageChange(currentPage);
			}
		}
	}

	function navigatePageFromThumbnail(page) {
		widgetNavBar.navigateBtn(page);
	}

	function onWidgetRegistered(widgetInfo) {
		// Hack to only allow tiles in general category if there is a demo tile
		if (feature.demoTiles().length !== 0 && widgetInfo.args && widgetInfo.args.thumbCategory !== "general")
			return;

		if (widgetInfo.args) {
			app.chooseTileScreen.createThumbnail(widgetInfo);
		}
		if(widgetInfo.args["baseTileWeight"]) {
			var baseTiles = p.baseSetTiles;
			var newBaseTile = {};

			newBaseTile.widgetInfo = widgetInfo;
			newBaseTile.baseTileWeight = widgetInfo.args["baseTileWeight"];

			baseTiles.push(newBaseTile);
			p.baseSetTiles = baseTiles;
		}
		if(widgetInfo.args["baseTileSolarWeight"]) {
			var baseTilesSolar = p.baseSetTilesSolar;
			baseTilesSolar.push({widgetInfo: widgetInfo, baseTileWeight: widgetInfo.args["baseTileSolarWeight"]});
			p.baseSetTilesSolar = baseTilesSolar;
		}
		if(widgetInfo.args["addAtSolarInstalled"]) {
			p.tileToAddAtSolarInstall = widgetInfo;
		}
	}

	function onWidgetDeregistered(widgetInfo) {
		// go thru all the tiles on the screen and remove the instances of the unregistered tile
		for(var i = 0; i < tileContainer.children.length; i++) {
			var page = tileContainer.children[i];
			for(var j = 0; j < page.children.length; j++) {
				var tile = page.children[j];
				if (tile.widgetInfo !== undefined && tile.widgetInfo.uid === widgetInfo.uid) {
					tile.removeTile();
				}
			}
		}
		app.chooseTileScreen.removeThumbnail(widgetInfo);
	}

	function removeTile(page, position) {
		createTile({context: null, url: emptyTileUrl}, page, position);
		// The previous call always increments tiles count therefore -2 to get number of non-empty tiles.
		tilesCount -= 2;
		// kpiTimer.restart(); - already restarted by the previous call
	}

	function replaceNewTile(container, index) {
		var newTile = container.children[container.children.length - 1];
		var oldTile = container.children[index];

		// pop new tile previously added at the end of container
		newTile.visible = false;
		newTile.parent = null;

		// remove replaced tile
		oldTile.visible = false;
		oldTile.parent = null;
		oldTile.destroy();

		var tileBuffer = [];

		// move tiles after insertion point to buffer
		while (container.children.length > index) {
			var tempTile = container.children[index];
			tileBuffer.push(tempTile);
			tempTile.visible = false;
			tempTile.parent = null;
		}

		// add new tile at the insertion point
		newTile.parent = container;
		newTile.visible = true;

		// add tiles back from buffer
		for (var i = 0; i < tileBuffer.length; i++) {
			tileBuffer[i].parent = container;
			tileBuffer[i].visible = true;
		}

		// check if container we have been replacing tiles in is now empty
		if (container.empty && !newTile.isEmptyTile) {
			container.empty = false;
		} else if (!container.empty && newTile.isEmptyTile) {
			container.empty = true;
			for ( i = 0; i <container.children.length; i++) {
				if (!container.children[i].isEmptyTile) {
					container.empty = false;
					break;
				}
			}
		}
	}

	function insertTileAtPosition(tileWidgetInfo, page, position, uuid) {
		var insertionPage = tileContainer.children[page];
		var currentTile;
		if (insertionPage)
			currentTile = insertionPage.children[position];

		if (currentTile && currentTile.isEmptyTile) {
			createTile(tileWidgetInfo, page, position, uuid);
		} else {
			var firstEmptyPos = getFirstEmptyTilePos();
			var emptyTile = tileContainer.children[firstEmptyPos[0]].children[firstEmptyPos[1]];
			emptyTile.parent = null;
			emptyTile.destroy();
			var tile;
			var pageIndex = firstEmptyPos[0];
			var posIndex = firstEmptyPos[1] - 1;
			for (; pageIndex >= page; pageIndex--) {
				var currentPage = tileContainer.children[pageIndex];
				for (; (pageIndex > page && posIndex >= 0) || (pageIndex === page && posIndex >= position); posIndex--) {
					tile = tileContainer.children[pageIndex].children[posIndex];
					tile.position++;
					saveTileToConfig(tile.widgetInfo.url, tile.page, tile.position, tile.uuid, tile.widgetArgs);
				}
				if (pageIndex > page) {
					var prevPage = tileContainer.children[pageIndex - 1];
					var lastTilePrevPage = prevPage.children[prevPage.children.length - 1];
					util.insertItemAt(lastTilePrevPage, currentPage, 0)
					lastTilePrevPage.page = pageIndex;
					lastTilePrevPage.position = 0;
					if (currentPage.empty) {
						currentPage.empty = false;
						createPage();
					}
					saveTileToConfig(lastTilePrevPage.widgetInfo.url, lastTilePrevPage.page, lastTilePrevPage.position, lastTilePrevPage.uuid, lastTilePrevPage.widgetArgs);
					posIndex = prevPage.children.length - 1;
				}
			}
			var placeholderTile = util.loadComponent(emptyTileUrl, currentPage, {});
			util.insertItemAt(placeholderTile, currentPage, position)
			createTile(tileWidgetInfo, page, position, uuid);
		}
	}

	function getFirstEmptyTilePos() {
		for (var page = 0; page < tileContainer.children.length; page++) {
			var pageContainer = tileContainer.children[page];
			for (var pos = 0; pos < pageContainer.children.length; pos++) {
				if (pageContainer.children[pos].isEmptyTile) {
					// if checked tile is emptyTile then this is first of its kind
					return [page, pos]
				}
			}
		}
		console.assert(false, "Cannot find any empty tile!");
		return;
	}

	function showChooseTileScreen() {
		if (app.chooseTileScreen) {
			app.chooseTileScreen.show();
		}
	}

	function saveTileToConfig(url, page, position, uuid, widgetArgs) {
		var saveTileMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, configMsgUuid, "ConfigProvider", "SetObjectConfig");
		saveTileMessage.addArgument("Config", null);

		var configNode = saveTileMessage.getArgumentXml("Config");
		configNode.addChild("package", "qt-gui", 0);

		var tileNode = configNode.addChild("tile", null, 0);
		tileNode.addChild("package", "qt-gui", 0);
		// If we don't have an uuid let hcb_config create one for us
		if (uuid)
			tileNode.addChild("uuid", uuid, 0);

		// It converts the absolute url relative to qml dir by removing the part that is the absolute path to qml directory
		var relTilePath = util.absoluteToRelativePath(url);

		tileNode.addChild("url", relTilePath, 0);
		tileNode.addChild("page", page, 0);
		tileNode.addChild("position", position, 0);
		if (widgetArgs && widgetArgs.config) tileNode.addChild("config", JSON.stringify(widgetArgs.config), 0);

		bxtClient.sendMsg(saveTileMessage);
	}

	function removeTileFromConfig(uuid) {
		var removeTileMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, configMsgUuid, "ConfigProvider", "SetObjectConfig");
		removeTileMessage.addArgument("Config", null);

		var configNode = removeTileMessage.getArgumentXml("Config");
		configNode.addChild("package", "qt-gui", 0);

		var tileNode = configNode.addChild("tile", null, 0);
		tileNode.addChild("package", "qt-gui", 0);
		tileNode.addChild("uuid", uuid, 0);
		tileNode.addChild("isZombie", 1, null);

		bxtClient.sendMsg(removeTileMessage);
	}

	function changeNextPagesConfig(startPage, pageChange) {
		var pages = tileContainer.children

		for (var i = startPage; i < pages.length; i++) {
			var page = pages[i];

			for(var j = 0; j < page.children.length; j++) {
				var tile = page.children[j];
				if (!tile.isEmptyTile) {
					saveTileToConfig(tile.widgetInfo.url, tile.page + pageChange, tile.position, tile.uuid, tile.widgetArgs);
				}
			}
		}
	}

	function updateTileConfig(url, tile, uuid) {
		var nextPageNum = tile.page + 1;
		var currentPage = tileContainer.children[tile.page];
		var nextPage = tileContainer.children[nextPageNum];

		// if tile is an empty tile remove tile node from configuration
		if (tile.isEmptyTile) {
			var tileToRemove = currentPage.children[tile.position];
			removeTileFromConfig(tileToRemove.uuid);
			var tmp = instantiatedTiles;
			tmp[uuid] = null;
			instantiatedTiles = tmp;

			// check if page is empty
			currentPage.empty = true;
			for (var i = 0; i < currentPage.children.length; i++) {
				if (i !== tile.position) {
					if (!currentPage.children[i].isEmptyTile) {
						currentPage.empty = false;
					}
				}
			}

			// if page is empty and next page is not update(deincrement) page property of tiles from next page
			if (currentPage.empty && !nextPage.empty) {
				changeNextPagesConfig(nextPageNum, -1);
			}
		}
		// if tile in not an empty tile add tile node to configuration
		else {
			// if uuid is passed (tile loaded from config) save uuid to tile
			if (uuid) {
				tile.uuid = uuid;
			}
			// if uuid not passed (newly created tile) generate uuid and save tile to config
			else {
				// if page is empty and there are tiles on next page update(increment) page property of tiles from next page
				if (nextPage) {
					if (currentPage.empty && !nextPage.empty) {
						changeNextPagesConfig(nextPageNum, 0);
					}
				}
				// Generate a uuid here because setObjectConfig doesn't return created uuid
				tile.uuid = bxtClient.getNewUuid();
				saveTileToConfig(url, tile.page, tile.position, tile.uuid, tile.widgetArgs);
			}
		}
	}

	function loadTileConfig() {
		var loadTileMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, configMsgUuid, "ConfigProvider", "GetPackageConfig");

		loadTileMessage.addArgument("PackageName", "qt-gui");
		bxtClient.doAsyncBxtRequest(loadTileMessage, loadTileConfigCallback, 2000);
	}

	function saveBaseSetTilesStatus(status) {
		var saveBaseTileDoneMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, configMsgUuid, "ConfigProvider", "SetObjectConfig");
		saveBaseTileDoneMessage.addArgument("Config", null);

		var configNode = saveBaseTileDoneMessage.getArgumentXml("Config");
		var qtConfigNode = configNode.addChild("qtConfig", null, 0);
		qtConfigNode.addChild("package", "qt-gui", 0);
		qtConfigNode.addChild("internalAddress", "qtConfig", 0);
		qtConfigNode.addChild("baseSetTilesLoaded", status, 0);
		p.baseSetTilesStatus = status;

		bxtClient.sendMsg(saveBaseTileDoneMessage);
	}

	function logTilePlacement() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, configMsgUuid, "ConfigProvider", "GetPackageConfig");
		msg.addArgument("PackageName", "qt-gui");
		bxtClient.doAsyncBxtRequest(msg, getTilePlacementConfigCallback, 30);
	}

	function rotateTiles() {
		var endPage = pagecount;
		endPage -= 1;
		var nextPage = currentPage + 1;
		if (nextPage === endPage)
			widgetNavBar.navigateBtn(0);
		else
			widgetNavBar.navigateBtn(nextPage);
	}

	onShown: {
		if (restorePage !== -1) {
			navigatePageFromThumbnail(restorePage);
			restorePage = -1;
		} else {
			navigatePageFromThumbnail(0);
		}
	}

	Component.onCompleted: {
		registry.registerWidgetContainer("prominent", rightPanelContainer)
		registry.registerWidgetContainer("prominentTabButton", rightPanelTabContainer)
	}

	Connections {
		target: screenStateController
		onScreenStateChanged: {
			if (screenStateController.screenState == ScreenStateController.ScreenColorDimmed && displaySettings.rotateTiles) {
				rotateTilesTimer.restart();
				// If we are at the last empty page move already to the first page.
				if (currentPage === (pagecount -1))
					widgetNavBar.navigateBtn(0);
			} else if (screenStateController.screenState !== ScreenStateController.ScreenDimmed) {
				widgetNavBar.navigateBtn(0);
				rotateTilesTimer.stop();
			}
		}
	}

	Row {
		id: container
		anchors {
			fill: parent
			leftMargin: tilesPerPage === 6 ? Math.round(45 * horizontalScaling) : Math.round(32 * horizontalScaling)
			rightMargin: anchors.leftMargin
		}
		spacing: Math.round(24 * horizontalScaling)
		layoutDirection: prominentLeft ? Qt.RightToLeft : Qt.LeftToRight

		Item {
			id: leftPanel
			width: tileContainer.children.length ? tileContainer.children[0].width : 0
			height: parent.height

			UnFlickable {
				id: tileContainerParent
				width: parent.width
				height: Math.round(352 * verticalScaling)
				anchors {
					left: parent.left
					top: parent.top
				}
				boundsBehavior: Flickable.StopAtBounds
				flickableDirection: Flickable.HorizontalFlick
				clip: true

				Row {
					id: tileContainer
					anchors.top: parent.top
					anchors.topMargin: Math.round(22 * verticalScaling)
					spacing: designElements.spacing10
				}
			}

			DottedSelector {
				id: widgetNavBar
				width: parent.width
				anchors {
					horizontalCenter: tileContainerParent.horizontalCenter
					verticalCenter: parent.bottom
					verticalCenterOffset: -33
				}
				visible: !dimState
				maxPageCount: 14
				pageCount: pagecount
				onNavigate: navigatePage(page)
			}
		}

		Item {
			id: rightPanel
			visible: (rightPanelContainer.children.length > 0)
			width: Math.round(248 * horizontalScaling)
			anchors {
				top: parent.top
				topMargin: Math.round(22 * verticalScaling)
				bottom: parent.bottom
				bottomMargin: anchors.topMargin
			}

			FeedbackButton {
				id: rightPanelFeedbackBtn
				anchors {
					top: rightPanel.top
					topMargin: - designElements.vMargin5
					left: rightPanel.left
					leftMargin: designElements.hMargin20
				}
				position: FeedbackButton.Position.Top
				targets: ["action:changeSetpoint","element:sidePanel"]
				z: 999

				Item {
					states: [
						State {
							name: "centered"
							when: rightPanelTabContainer.children.length > 1
							AnchorChanges { target: rightPanelFeedbackBtn; anchors.left: undefined; anchors.horizontalCenter: rightPanel.horizontalCenter }
						}
					]
				}
			}

			Item {
				anchors.fill: parent
				clip: true

				StyledRectangle {
					id: rightPanelTabs
					width: parent.width
					height: Math.round(44 * verticalScaling)
					color: canvas.dimState ? colors.none : colors.inactiveBackground
					radius: designElements.radius
					bottomLeftRadiusRatio: 0
					bottomRightRadiusRatio: 0

					Row {
						id: rightPanelTabContainer
						anchors.fill: parent

						function onWidgetRegistered(widgetInfo) {
							console.log("prominent tab button registered: " + widgetInfo.url);
							var obj = util.loadComponent(widgetInfo.url, rightPanelTabContainer, {app: widgetInfo.context});
							if (obj) {
								obj.initWidget(widgetInfo);
								obj.showPanel.connect(onTabButtonClicked);
								// Update all buttons of the amount of buttons now visible
								for (var i = 0; i < rightPanelTabContainer.children.length; ++i) {
									rightPanelTabContainer.children[i].nrTabButtons = rightPanelTabContainer.children.length;
								}
								// The first button (the one from thermostat) will be made active immediately
								// Later buttons start as inactive
								if (rightPanelTabContainer.children.length === 1) {
									obj.state = "active";
								} else {
									obj.state = "inactive";
								}
							}

							navigateToFirstTab();
						}

						function onWidgetDeregistered(widgetInfo) {
							console.log("Remove", widgetInfo.url, widgetInfo.uid);
							for (var i = 0; i < rightPanelTabContainer.children.length; ++i) {
								var curChild = rightPanelTabContainer.children[i];
								if (curChild.widgetInfo !== undefined && curChild.widgetInfo.uid === widgetInfo.uid) {
									console.log("Found child with widget.uid", widgetInfo.uid);
									curChild.visible = false;
									curChild.parent = null;
									curChild.destroy();
									break;
								}
							}

							for (i = 0; i < rightPanelTabContainer.children.length; ++i) {
								rightPanelTabContainer.children[i].nrTabButtons = rightPanelTabContainer.children.length;
							}

							navigateToFirstTab();
						}

						function navigateToFirstTab() {
							if (rightPanelTabContainer.children.length > 0) {
								// Navigate back to the first panel
								onTabButtonClicked(rightPanelTabContainer.children[0].panelUrl);
							}
						}

						function onTabButtonClicked(panelUrl) {
							// Iterate over the panels to show the one corresponding to the panelUrl
							for (var i = 0; i < rightPanelContainer.children.length; ++i) {
								var curObj = rightPanelContainer.children[i];
								// We need the "==" here to compare the url values instead of the (object) instances
								if (curObj.sourceUrl == panelUrl) {
									rightPanelFlickable.contentX = rightPanelFlickable.width * i + rightPanelContainer.spacing * i;
								}
							}

							// Iterate over the tab buttons to activate the one corresponding to the panelUrl
							for (var j = 0; j < rightPanelTabContainer.children.length; ++j) {
								var curBtn = rightPanelTabContainer.children[j];
								// We need the "==" here to compare the url values instead of the (object) instances
								if (curBtn.panelUrl == panelUrl) {
									curBtn.state = "active";
								} else {
									curBtn.state = "inactive";
								}
							}
						}
					}
				}

				StyledRectangle {
					id: rightPanelBg
					anchors {
						left: parent.left
						right: parent.right
						top: rightPanelTabs.bottom
						bottom: parent.bottom
					}
					color: canvas.dimState ? colors.none : colors.contrastBackground
					radius: rightPanelTabs.radius
					topLeftRadiusRatio: 0
					topRightRadiusRatio: 0

					UnFlickable {
						id: rightPanelFlickable
						anchors.fill: parent
						contentWidth: rightPanelContainer.width

						Row {
							id: rightPanelContainer
							height: parent.height
							spacing: designElements.spacing8
							z: 1

							function onWidgetRegistered(widgetInfo) {
								console.log("prominent widget registered: " + widgetInfo.url);
								var obj = util.loadComponent(widgetInfo.url, rightPanelContainer, {app: widgetInfo.context});
								if (obj) {
									obj.initWidget(widgetInfo);
								}
							}

							function onWidgetDeregistered(widgetInfo) {
								console.log("Remove", widgetInfo.url, widgetInfo.uid);
								for (var i = 0; i < rightPanelContainer.children.length; ++i) {
									var curChild = rightPanelContainer.children[i];
									if (curChild.widgetInfo !== undefined && curChild.widgetInfo.uid === widgetInfo.uid) {
										console.log("Found child with widget.uid", widgetInfo.uid);
										curChild.visible = false;
										curChild.parent = null;
										curChild.destroy();
										break;
									}
								}
							}
						}
					}
				}
			}
		}
	}

	IconButton {
		id: rotateTilesToggle
		anchors {
			left: parent.left
			leftMargin: designElements.hMargin15
			bottom: parent.bottom
			bottomMargin: designElements.vMargin10
		}
		width: height
		visible: dimState

		colorUp: dimColors.btnUp
		colorUpPrimary: dimColors.btnUpPrimary
		colorDown: dimColors.btnDown
		colorDownPrimary: dimColors.btnDownPrimary
		colorSelected: dimColors.btnSelected
		colorDisabled: dimColors.btnDisabled

		mouseIsActiveInDimState: true
		iconSource: "drawables/rotate-" + (selected ? "off" : "on") + ".svg"
		selected: !displaySettings.rotateTiles

		onClicked: {
			displaySettings.rotateTiles = !displaySettings.rotateTiles;
			if (displaySettings.rotateTiles) {
				rotateTilesTimer.restart();
			} else {
				rotateTilesTimer.stop();
				widgetNavBar.navigateBtn(0);
			}
		}
	}

	BxtDiscoveryHandler {
		deviceType: "hcb_config"
		onDiscoReceived: {
			configMsgUuid = deviceUuid;
			if(!p.tileConfigLoaded)
				dependencyResolver.setDependencyDone("Homescreen.uuidConfig");
		}
	}

	BxtRequestCallback {
		id: loadTileConfigCallback
		onMessageReceived: {
			p.loadingBaseSet = true;
			if (!p.tileConfigLoaded) {
				var qtConfigNode = message.getArgumentXml("Config").getChild("qtConfig");
				p.baseSetTilesStatus = qtConfigNode ? parseInt(qtConfigNode.getChildText("baseSetTilesLoaded")) : 0;
				if (p.baseSetTilesStatus == 0) {
					// Qt starts for the first time. Now load the baseset of tiles.
					// To add a tile to a baseset it must be added as argument when registering a tile

					// Sort the baseset of tiles upon their weight
					var baseTiles = p.baseSetTiles;
					baseTiles.sort(function (a, b) {return a.baseTileWeight - b.baseTileWeight;})

					// Create the base set of tiles
					var tileIndex=0;
					var pageIndex=0;
					for (var i=0; i<baseTiles.length; i++) {
						createTile(baseTiles[i].widgetInfo, pageIndex, tileIndex);

						if(tileIndex === (tilesPerPage - 1)) {
							tileIndex = 0;
							pageIndex++
						} else {
							tileIndex++;
						}
					}
					saveBaseSetTilesStatus(1);
					globals.startWhatIsToon();
				} else {
					var loadedTile = message.getArgumentXml("Config").getChild("tile");
					if (loadedTile) {
						for (; loadedTile; loadedTile = loadedTile.next) {
							var isZombie = loadedTile.getChild("isZombie");
							var uuid = loadedTile.getChild("uuid");
							if (!uuid)
								continue;

							uuid = uuid.text;
							//if isZombie property is not present(tile not in progress of deletion) create this tile
							if (!isZombie && !instantiatedTiles[uuid]) {
								var url = loadedTile.getChild("url");
								var page = loadedTile.getChild("page");
								var position = loadedTile.getChild("position");
								var configNode = loadedTile.getChild("config");
								if (!url || !page || !position)
								{
									hcblog.logKpi("incomplete tile deleted", uuid);
									hcblog.logMsg(99, "incomplete tile deleted: " + uuid);
									removeTileFromConfig(uuid);
									continue;
								}

								url.text = url.text.replace("/weatherInt/", "/weather/"); // WeatherInt was deleted

								url = Qt.resolvedUrl("qrc:/" + url.text); // convert the relative path to the absolute one
								page = parseInt(page.text);
								position = parseInt(position.text);

								//if tile will be created on page which does not exist - create pages
								if (pagecount <= page) {
									for (var i = pagecount; i <= page; i++) {
										createPage();
									}
								}

								var tileWidgetInfo;
								var defaultWidgetInfo = registry.getWidgetInfo("tile", url);

								// Get the appName out of the url to find out if the tile may be loaded or must be removed from the config according the product options
								var urlParts = url.split("/");
								var appName = urlParts[urlParts.length - 2]; //keep in mind that since array starts with 0, last part is [length - 1]

								var tmp = instantiatedTiles;
								if (globals.enabledApps.indexOf(appName) > -1) {
									if (!defaultWidgetInfo) {
										console.log("Trying to load unregistered tile " + url + " from config");
										hcblog.logKpi("missingTileRegistrationInfo", url);
										continue;
									}
									if (configNode) {
										//Copy the widgetInfo, since we will be parsing our own config. Otherwise we would be changing the registered widgetInfo.
										tileWidgetInfo = {};
										for (var q in defaultWidgetInfo) tileWidgetInfo[q] = defaultWidgetInfo[q];
										tileWidgetInfo.args = {}
										for (var a in defaultWidgetInfo.args) tileWidgetInfo.args[a] = defaultWidgetInfo.args[a];
										tileWidgetInfo.args.config = JSON.parse(configNode.text);
									} else {
										tileWidgetInfo = defaultWidgetInfo;
									}

									createTile(tileWidgetInfo, page, position, uuid);
									tmp[uuid] = 1;
								} else {
									removeTileFromConfig(uuid);
									tmp[uuid] = null;
								}
								instantiatedTiles = tmp;
							}
						}
					} else {
						console.log("No tile configuration available");
					}
				}
			}
			dependencyResolver.setDependencyDone("Homescreen.loadTiles");
			p.loadingBaseSet = false;
			p.tileConfigLoaded = true;
		}
	}


	BxtRequestCallback {
		id: getTilePlacementConfigCallback
		onMessageReceived: {
			var tileNode = message.getArgumentXml("Config").getChild("tile");
			if (tileNode) {
				var tilePlacement = {};
				for (; tileNode; tileNode = tileNode.next) {
					var isZombie = tileNode.getChild("isZombie");
					var uuid = tileNode.getChild("uuid");
					if (!uuid)
						continue;

					uuid = uuid.text;
					//if isZombie property is not present(tile not in progress of deletion) log this tile
					if (!isZombie) {
						var url = tileNode.getChild("url");
						var page = tileNode.getChild("page");
						if (url && page) {
							url = url.text
							page = parseInt(page.text) + 1;
							var tileName;
							try {
								tileName = url.match("[^/]+/([^\.]+)")[1];
							} catch(e) {
								tileName = url;
							}
							tileName = tileName.replace("/",":");

							if (typeof tilePlacement[tileName] === "undefined" || page < tilePlacement[tileName])
								tilePlacement[tileName] = page;
						}
					}
				}
				// add prefix "Page" to tile placement segmentation values
				for (var tile in tilePlacement)
					tilePlacement[tile] = "Page " + tilePlacement[tile];

				countly.sendEvent("TilePlacement", null, null, -1, tilePlacement);
			} else {
				console.log("No tile configuration available");
			}
		}
	}

	/**
	 * @brief This timer generates KPI logs of variables that might be changed to often in a short period of time
	 * and consequently generate to many logs.
	 *
	 * The timer should be restarted when a variable that needs to be logged is changed.
	 */
	Timer {
		id: kpiTimer
		interval: 15000

		onTriggered: {
			hcblog.logKpi("tilesCount", tilesCount);
			hcblog.logKpi("tilePagesCount", pagecount);
		}
	}


	Timer {
		id: rotateTilesTimer
		interval: 5000
		repeat: true
		running: false
		onTriggered: {
			rotateTiles();
		}
	}
}

