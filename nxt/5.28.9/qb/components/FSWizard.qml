import QtQuick 2.1

Screen {
	id: wizardScreen
	screenTitle: "Wizard screen"
	hasCancelButton: true
	hasBackButton: false
	hasHomeButton: false

	inNavigationStack: false

	readonly property string _TEXT_NEXT: qsTr("Next")
	readonly property string _TEXT_CONTINUE: qsTr("Continue")
	readonly property string _TEXT_DONE: qsTr("Done")

	property string intermediateRightButtonText: _TEXT_CONTINUE
	property string finalRightButtonText: _TEXT_DONE

	property real contentMargins: Math.round(16 * verticalScaling)

	// frames are shown in order
	property var frameUrls: []
	property url nextScreenUrl: ""

	QtObject {
		id: p
		property int currentFrame: -1

		onCurrentFrameChanged: {
			if (p.currentFrame >= 0 && p.currentFrame <= (frameUrls.length -1)) {
				enableCustomTopRightButton();

				// only enable cancel button for first frame, others can change on demand
				if (p.currentFrame === 0)
					enableCancelButton();
				else
					disableCancelButton();

				// set right button text accordingly
				if (p.currentFrame !== (frameUrls.length -1))
					addCustomTopRightButton(intermediateRightButtonText);
				else
					addCustomTopRightButton(finalRightButtonText);

				if (loader.item !== null) {
					if (loader.item.hidden instanceof Function)
						loader.item.hidden();
				}
				loader.loaded.connect(function onLoaded() {
					if (loader.item.shown instanceof Function)
						loader.item.shown(undefined);
					loader.loaded.disconnect(onLoaded);
				});
				loader.setSource(frameUrls[p.currentFrame], {"app": app, "parentScreen": wizardScreen});
			}
		}

		function checkCanContinue() {
			if (loader.item !== null) {
				var canContinue = loader.item.canContinue;
				if (canContinue !== undefined) {
					if (canContinue)
						enableCustomTopRightButton();
					else
						disableCustomTopRightButton();
				}
			}
		}
	}

	function navigateToFrame(frame) {
		navigateToFrameNr(frameUrls.indexOf(frame))
	}

	function navigateToFrameNr(frameNr) {
		if (frameNr >= 0 && frameNr < frameUrls.length) {
			p.currentFrame = frameNr;
		}
	}

	onCustomButtonClicked: {
		if (loader.item !== null) {
			if (loader.item.next instanceof Function)
				loader.item.next();
		}
		if (p.currentFrame < (frameUrls.length -1)) {
			p.currentFrame++;
		} else if (nextScreenUrl.toString().length > 0) {
			console.log("Opening next screen:", nextScreenUrl.toString());
			stage.openFullscreen(nextScreenUrl);
		} else {
			hide();
		}
	}

	onCanceled: {
		if (loader.item !== null) {
			if (loader.item.canceled instanceof Function)
				loader.item.canceled();
		}
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		if (args && args.frameUrl)
			navigateToFrame(args.frameUrl)
		else
			p.currentFrame = 0;
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
		if (loader.item !== null) {
			if (loader.item.hidden instanceof Function)
				loader.item.hidden();
		}
	}

	Connections {
		target: loader.item
		ignoreUnknownSignals: true
		onCanContinueChanged: p.checkCanContinue()
	}

	Rectangle {
		id: backgroundRect
		anchors {
			fill: parent
			margins: Math.round(16 * verticalScaling)
		}
		radius: designElements.radius
		color: colors.contentBackground
		clip: true

		Loader {
			id: loader
			anchors.fill: parent
			onItemChanged: p.checkCanContinue()
		}
	}
}
