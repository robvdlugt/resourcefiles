import QtQuick 2.1
import BxtClient 1.0
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0

App {
	id: imageViewerApp

	property url path: "file:///qmf/var/qt-gui/apps/imageViewer"
	property Popup slideshowPopup
	property alias imageList: imageList

	property string lanIp: ""

	QtObject {
		id: p

		property url imageViewerScreenUrl: "ImageViewerScreen.qml"
		property url imageViewerSlideshowUrl: "ImageViewerSlideshowPopup.qml"
		property url imageViewerMenuUrl: "drawables/ImageViewerIcon.svg"
	}


	function init() {
		registry.registerWidget("screen", p.imageViewerScreenUrl, imageViewerApp, null, {lazyLoadScreen: true});
		registry.registerWidget("popup", p.imageViewerSlideshowUrl, imageViewerApp, "slideshowPopup", {lazyLoadScreen: true});
		registry.registerWidget("menuItem", null, imageViewerApp, null, {objectName: "imageViewerMenuItem", label: qsTr("Image viewer"), image: p.imageViewerMenuUrl, screenUrl: p.imageViewerScreenUrl, weight: 135});
	}


	function startSlideshow(autoplay) {
		slideshowPopup.autoplay = autoplay;
		slideshowPopup.show();
	}

	function stopSlideshow() {
		slideshowPopup.hide();
	}


	function reloadImageList() {
		imageList.clear();

		fileList.source = Qt.resolvedUrl(path);
		var images = fileList.entryList(["*.jpg", "*.png"]);
		for(var i in images) {
			imageList.append({path: path.toString(), file: images[i]});
		}
	}


	BxtDiscoveryHandler {
		id : netconDiscoHandler
		deviceType: "hcb_netcon"
		onDiscoReceived: {
			statusNotifyHandler.sourceUuid = deviceUuid;
		}
	}

	BxtNotifyHandler {
		id: statusNotifyHandler
		serviceId: "gwif"
		onNotificationReceived : {
			var address = message.getArgument("ipaddress");
			if (address) {
				lanIp = address;
			}
		}
	}

	ListModel {
		id: imageList
	}

	FileIO {
		id: fileList
	}
}
