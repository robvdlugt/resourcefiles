import QtQuick 2.0
import QtTest 1.0

import BxtClient 1.0
import BxtTestbench 1.0

import themes 1.0

import qb.test 1.0
import qb.components 1.0
import qb.registry 1.0
import qb.stage 1.0
import qb.base 1.0
import qb.lang 1.0
import qb.utils 1.0
import qb.notifications 1.0

TestCase {
	property BxtClient bxtClient: BxtClient{}
	property BxtFactory bxtFactory: BxtFactory{}
	property Registry registry: Registry{}
	property DependencyResolver dependencyResolver: DependencyResolver{}
	property Globals globals: Globals{}
	property Colors colors: TenantNormalColors{}
	property DimColors dimColors: TenantDimColors{}
	property I18n i18n: I18n_nl_NL{}
	property Fonts qfont: Fonts{}
	property Stage stage: Stage{}
	property Notifications notifications: Notifications{}
	property Util util: Util{}
	property DesignElements designElements: DesignElements {}
	property QbCanvas canvas: QbCanvas { stage: stage }
}

