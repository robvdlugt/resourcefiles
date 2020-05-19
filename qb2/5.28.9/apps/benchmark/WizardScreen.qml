import QtQuick 2.1
import qb.components 1.0

Screen {
	id: wizardScreen
	property alias outcomeData: selectorWizard.frameData
	property alias selectorWizardFrames: selectorWizard.frameUrls
	property alias selectorWizardSelector: selectorWizard.selector

	function init(app) {
		selectorWizard.frameUrls = [
			app.houseTypeFrameUrl,
			app.apartmentOptionsFrameUrl,
			app.constructionPeriodFrameUrl,
			app.surfaceAreaFrameUrl,
			app.familySizeFrameUrl,
			app.nameFrameUrl,
			app.profileOverviewFrameUrl
		];
	}

	hasCancelButton: true

	onCustomButtonClicked: {
		app.enableBenchmark(outcomeData[0], outcomeData[1], outcomeData[3].size, outcomeData[2], outcomeData[4], outcomeData[5]);
		selectorWizard.clear();
		stage.navigateHome();
		if (app.openBenchmarkAfterWizard) {
			stage.openFullscreen(app.benchmarkScreenUrl);
		}
	}

	onShown: {
		if (args && args.reset === true) {
			selectorWizard.selector.navigateBtn(0);
		}
		screenStateController.screenColorDimmedIsReachable = false;
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onCanceled: {
		selectorWizard.clear();
	}

	SelectorWizard {
		id: selectorWizard
		customNextPage: true
	}
}
