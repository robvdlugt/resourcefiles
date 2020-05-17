import QtQuick 2.1

import qb.components 1.0

BasePopup {
	id: securityPopup
	hideCloseBtn: true

	onShown: {
		if (args && args.contentUrl) {
			setContent(args.contentUrl, args.contentArgs)
		}
	}

	onHidden: {
		setContent("");
	}
}
