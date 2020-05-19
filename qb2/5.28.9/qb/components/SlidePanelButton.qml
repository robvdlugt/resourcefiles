import QtQuick 2.1

import qb.base 1.0
import BasicUIControls 1.0;
import ScreenStateController 1.0

StyledRectangle {
	id: root

	property string kpiId: "SlidePanel." + imageSource.split("/").pop().split(".").shift() // gets filename
	property string imageSource
	property bool imageMirror: false
	property Widget widgetObject
	property bool selected: widgetObject ? widgetObject.showing : false
	property bool first: false
	property bool last: false

	signal tabClicked(variant widgetInfo)

	QtObject {
		id: p
		property bool slidePanelLeft: !screenStateController.prominentWidgetLeft
	}

	width: height
	height: Math.round(64 * verticalScaling)
	color: canvas.dimState ? colors.globalBackground : (root.parent && root.parent.panelOpen ? colors.canvas : colors.background)
	visible: (widgetObject != null) && (widgetObject.enabled === true)

	radius: (height / 2)
	topLeftRadiusRatio: p.slidePanelLeft ? 0 : 1
	topRightRadiusRatio: p.slidePanelLeft ? 1 : 0
	bottomLeftRadiusRatio: topLeftRadiusRatio
	bottomRightRadiusRatio: topRightRadiusRatio

	mouseIsActiveInDimState: true

	leftClickMargin: designElements.hMargin15
	rightClickMargin: designElements.hMargin15
	topClickMargin: first ? designElements.vMargin20 : 0
	bottomClickMargin: last ? designElements.vMargin20: 0

	Image {
		id: shadow
		anchors.top: parent.top
		source: "qrc:/images/slidepanelbutton_shadow.png"
		height: parent.height
		visible: root.parent ? root.parent.panelOpen && !selected : false
		mirror: !p.slidePanelLeft

		Connections {
			target: p
			onSlidePanelLeftChanged: shadow.setAnchors()
		}

		Component.onCompleted: setAnchors()

		function setAnchors() {
			if (p.slidePanelLeft) {
				anchors.right = undefined;
				anchors.left = parent.left;
			} else {
				anchors.left = undefined;
				anchors.right = parent.right;
			}
		}
	}

	Image {
		id: image
		anchors {
			horizontalCenterOffset: -(parent.width - width) / 6
			centerIn: parent
		}
		source: canvas.dimState ? imageSource.replace(/(\.[\w\d_-]+)$/i, '_dim$1') : imageSource
		mirror: imageMirror ? !p.slidePanelLeft : false
	}

	StyledRectangle {
		id: bgShadow
		width: parent.width
		height: parent.height
		radius: parent.radius
		color: colors.slidePanelButtonShadow
		visible: !canvas.dimState
		mouseEnabled: false
		x: 1
		y: 1
		z: -1

		topLeftRadiusRatio: parent.topLeftRadiusRatio
		topRightRadiusRatio: parent.topRightRadiusRatio
		bottomLeftRadiusRatio: parent.bottomLeftRadiusRatio
		bottomRightRadiusRatio: parent.bottomRightRadiusRatio
	}

	onClicked: tabClicked(widgetObject.widgetInfo)
}
