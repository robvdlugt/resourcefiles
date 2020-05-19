.pragma library

var fullScreenHistory = [];
var loadedScreens = {};
var preLoadedScreens = {};
var registeredTiles = [];
var homescreenPopups = [];
var screenParent;
var Component;
var currentFullScreen;
var currentFullScreenComponent;
var menuScreenComponent;
var systrayContainer;
var popupContainer;
var screenTitleComponent;
var screenTitleIconComponent;
var topBarDefaultColors = {};

function init(parent, ComponentClass) {
	screenParent = parent;
	Component = ComponentClass;
}

function handleArgument(message, argName, fn) {
    var argVal = message.getArgument(argName);
    if(argVal !== "") {
        return fn(argVal);
    }
}

function getUuid(message) {
    var temp = message.split("uuid=\"");
    temp = temp[1].split(":");
    return temp[0];
}
