import QtQuick 2.1
import BasicUIControls 1.0

/**
  ThreeStateButton implements button with 3 defined states: "up", "down" and "disabled". Clickable area with
  size of the button is created and filled with background color (backgroundUp property).
  Button hold only the image (no text). Original image can be rotated using 'imgRotation' property.
  For image placed on the button shadow is created (moving original image [+2; +2] with opacity 20%.
  Disabled button has no shadow for the icon and color effect is applied on the original image.
  States "up" and "down" are handled via mouse click. Icon and button background is different for the states.
  */

Item {
	id: root
	width: Math.round(50 * horizontalScaling)
	height: Math.round(50 * verticalScaling)

	property url image
	property color backgroundUp
	property color backgroundDown
	property int imgRotation: 0
	property color buttonDownColor: colors.threeStateButtonIconDown
	property int iconMargin: 0
	property string iconAlign
	property alias iconSmooth: icon.smooth
	property alias color: buttonWrap.color
	property alias mouseIsActiveInDimState: buttonWrap.mouseIsActiveInDimState
	property alias bottomClickMargin: buttonWrap.bottomClickMargin
	property alias topClickMargin: buttonWrap.topClickMargin
	property alias leftClickMargin: buttonWrap.leftClickMargin
	property alias rightClickMargin: buttonWrap.rightClickMargin
	property string kpiPostfix: image.toString().split("/").pop().split(".").shift() + imgRotation

	onEnabledChanged: {
		root.state = enabled ? "up" : "disabled";
	}

	signal clicked;

	StyledRectangle {
		id: buttonWrap
		width: root.width
		height: root.height
		color: root.state === "down" ? backgroundDown : backgroundUp
		radius: designElements.radius
		mouseEnabled: root.state === "disabled" ? false  : true
		onPressed: root.state = "down"
		onReleased: root.state = "up"
		onClicked: root.clicked()
	}

	Image {
		id: icon
		rotation: imgRotation
		source: image.toString() ? "image://scaled/" + qtUtils.urlPath(image) : ""
		anchors {
			verticalCenter: !iconAlign ? parent.verticalCenter : undefined
			horizontalCenter: parent.horizontalCenter
			top: iconAlign === "top" ? parent.top : undefined
			topMargin: iconAlign === "top" ? iconMargin : 0
			bottom: iconAlign === "bottom" ? parent.bottom : undefined
			bottomMargin: iconAlign === "bottom" ? iconMargin : 0
		}
	}

	onStateChanged: {
		if (image.toString()) {
			var colorizeColor;
			if (state === "down")
				colorizeColor = buttonDownColor.toString();
			else if (state === "disabled")
				colorizeColor = colors.threeStateButtonDisabled.toString();

			if (colorizeColor)
				icon.source = "image://colorized/" + colorizeColor + qtUtils.urlPath(image);
			else
				icon.source = "image://scaled/" + qtUtils.urlPath(image)
		}
	}
}
