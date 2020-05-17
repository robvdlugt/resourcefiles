import QtQuick 2.11

import qb.components 1.0
import qb.base 1.0
import BasicUIControls 1.0

import BoilerDataListModel 1.0
import SortFilterProxyModel 0.1

EditScreen {
	id: root
	property int itemsPerPage: 4
	property int itemHeight: Math.round(36 * verticalScaling)

	QtObject {
		id: p
		property variant selectedId
		property variant selectedName
	}

	onScreenShown: {
		if (args) {
			if (typeof args.brandId === "number") {
				screenTitle = qsTr("Model");
				boilerModel.brandId = args.brandId;
				var modelId = app.boilerInfo.modelId;
				p.selectedId = modelId;
				p.selectedName = app.boilerModelName;
			}
		} else {
			screenTitle = qsTr("Brand");
			var brandId = app.boilerInfo.brandId;
			p.selectedId = brandId;
			p.selectedName = app.boilerBrandName;
		}
		boilerModel.fetch();
	}

	onScreenSaved: {
		if (boilerModel.brandId >= 0)
			app.setBoilerModel(p.selectedId, p.selectedName, root);
		else
			app.setBoilerBrand(p.selectedId, p.selectedName, root);
	}

	BoilerDataListModel {
		id: boilerModel
		fetchUuid: app.getApiUuid("boilerKnowledgeService")
		onFetchComplete: {
			if (p.selectedId && !fetchError) {
				var modelIdx = boilerModel.indexById(p.selectedId);
				var listIdx = boilerProxyModel.mapFromSource(modelIdx);
				scrollBar.currentIndex = listIdx;
				boilerList.positionViewAtIndex(scrollBar.currentIndex, ListView.Beginning);
				if (boilerList.atYEnd)
					scrollBar.currentIndex = boilerList.count - itemsPerPage;
				editText.text = p.selectedName;
			}
			fetchErrorText.visible = fetchError;
		}
	}

	SortFilterProxyModel {
		id: boilerProxyModel
		sourceModel: boilerModel
		sortRoleName: "name"
		sortCaseSensitivity: Qt.CaseInsensitive
		sortOrder: Qt.AscendingOrder
		filterRoleName: "name"
		filterPatternSyntax: SortFilterProxyModel.Wildcard
		filterCaseSensitivity: Qt.CaseInsensitive
	}

	StyledRectangle {
		id: editTextBg
		width: Math.round(400 * horizontalScaling)
		height: itemHeight
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: Qt.inputMethod.visible ? 0 : Math.round(50 * verticalScaling)
		}
		radius: designElements.radius
		color: colors._middlegrey

		TextInput {
			id: editText
			anchors {
				fill: parent
				margins: Math.round(8 * verticalScaling)
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors._harry

			onTextEdited: {
				boilerProxyModel.filterPattern = editText.text;
				p.selectedId = undefined;
				p.selectedName = undefined;
			}
		}

		Throbber {
			width: height
			height: parent.height
			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			animate: visible
			visible: boilerModel.fetching

			smallRadius: 1.5
			mediumRadius: 2
			largeRadius: 2.5
			bigRadius: 3
		}
	}

	ListView {
		id: boilerList
		height: (itemHeight * itemsPerPage) + (spacing * (itemsPerPage - 1))
		anchors {
			top: editTextBg.bottom
			topMargin: Math.round(4 * verticalScaling)
			left: editTextBg.left
			right: editTextBg.right
		}
		spacing: Math.round(4 * verticalScaling)
		clip: true
		interactive: false
		model: boilerProxyModel
		delegate: StyledRectangle {
			id: boilerDelegate
			anchors.left: parent.left
			anchors.right: parent.right
			height: itemHeight
			radius: designElements.radius
			color: colors.white
			property bool isCurrentItem: p.selectedId === model.id
			onClicked: {
				p.selectedId = model.id;
				p.selectedName = model.name;
				editText.text = p.selectedName;
			}

			Text {
				anchors {
					left: parent.left
					right: parent.right
					leftMargin: Math.round(10 * horizontalScaling)
					rightMargin: anchors.leftMargin
					verticalCenter: parent.verticalCenter
				}
				font {
					pixelSize: qfont.bodyText
					family: isCurrentItem ? qfont.semiBold.name : qfont.regular.name
				}
				text: model.name
				color: isCurrentItem ? colors._branding : colors._gandalf
				elide: Text.ElideRight
			}
		}
		onCountChanged: {
			scrollBar.currentIndex = 0;
			positionViewAtBeginning();
			if (count === 0)
				contentHeight = 0;
		}

		Text {
			id: fetchErrorText
			visible: false
			anchors {
				horizontalCenter: parent.horizontalCenter
				verticalCenter: parent.verticalCenter
			}
			color: colors.secondary
			font.family: qfont.regular.name
			font.pixelSize: qfont.bodyText
			text: qsTr("fetch-error")
		}
	}

	ScrollBar {
		id: scrollBar
		anchors {
			top: editTextBg.top
			bottom: boilerList.bottom
			left: boilerList.right
			leftMargin: designElements.hMargin15
		}
		container: boilerList
		laneColor: colors.white
		buttonSize: itemHeight
		property int currentIndex: 0
		onNext: {
			currentIndex = Math.min(currentIndex + itemsPerPage, boilerList.count - 1);
			boilerList.positionViewAtIndex(currentIndex, ListView.Beginning);
			if (boilerList.atYEnd)
				currentIndex = boilerList.count - itemsPerPage;
		}
		onPrevious: {
			currentIndex = Math.max(currentIndex - itemsPerPage, 0);
			boilerList.positionViewAtIndex(currentIndex, ListView.Beginning);
			if (boilerList.atYBeginning)
				currentIndex = 0;
		}
	}
}
