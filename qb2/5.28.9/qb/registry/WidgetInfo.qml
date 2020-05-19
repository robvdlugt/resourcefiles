import QtQuick 2.1

/*!
  Class used to store information about registered widgets
  */

QtObject {
	/// Url of the QML file the widget should be loaded from
	property url url
	/// Name of the propery in the app that should automagically point to the latest instantiation of the widget. Can be null if not used by the App.
	property string localName
	/// App that will be the owner of the instantiated widgets
	property App appContext
	/// Internal widget index
	property int widgetIndex
	/// Arguments that will be passed to the widgets' init
	property variant args
}
