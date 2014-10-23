import QtQuick 2.0
import WebView 1.0

Rectangle {
    id: root
    color: myApp.style.dark
    width: rootMenu.width
    height: rootMenu.height
//    x: myApp.style.splitViewSpacing

    readonly property Item menuGridRoot: root

    Timer {
        interval: 1
        onTriggered: rootMenu.openMenu(true, null);
        running: true
    }

    signal closeAllMenus()

    WebView {
        id: webView
        onImageUrlChanged: myApp.addImage(imageUrl);
    }

    ControlPanelSubMenu {
        id: rootMenu;
        ControlPanelButton {
            text: "!"
            menu: moreOptions
            gridX: 0; gridY: 0
            alwaysVisible: true
        }
    }

    ControlPanelSubMenu {
        id: moreOptions
        ControlPanelButton {
            text: ">"
            checkable: true
            onClicked: myApp.timeFlickable.togglePlay(checked)
            gridX: 0; gridY: -1
        }
        ControlPanelButton {
            text: "<<"
            onClicked: myApp.model.setTime(0);
            gridX: 0; gridY: -2
        }
        ControlPanelButton {
            text: "Record\noptions"
            menu: recordOption
            gridX: 0; gridY: -3
        }
        ControlPanelButton {
            text: "Keyframe"
            checkable: true
            onCheckedChanged: myApp.keyframeInfo.visible = checked
            gridX: 0; gridY: -4
        }
        ControlPanelButton {
            text: "[ ]"
            gridX: 0; gridY: -5
        }
        ControlPanelButton {
            text: "Sprites"
            onClicked: webView.search();
            gridX: 0; gridY: -6
        }
    }

    ControlPanelSubMenu {
        id: recordOption
        ControlPanelButton {
            text: "x & y"
            gridX: 0; gridY: 0 
            checked: myApp.model.recordsPositionX && myApp.model.recordsPositionY
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsPositionX = true;
                myApp.model.recordsPositionY = true;
            }
        }
        ControlPanelButton {
            text: "r & s"
            gridX: 0; gridY: 1
            checked: myApp.model.recordsRotation && myApp.model.recordsScale
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsScale = true;
                myApp.model.recordsRotation = true;
            }
        }
        ControlPanelButton {
            text: "Anchor\nx & y"
            gridX: 0; gridY: 2
            checked: myApp.model.recordsAnchorX && myApp.model.recordsAnchorY
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsAnchorX = true;
                myApp.model.recordsAnchorY = true;
            }
        }
        ControlPanelButton {
            text: "x"
            gridX: 1; gridY: 0
            checked: myApp.model.recordsPositionX && !myApp.model.recordsPositionY
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsPositionX = true;
            }
        }
        ControlPanelButton {
            text: "y"
            gridX: 2; gridY: 0
            checked: !myApp.model.recordsPositionX && myApp.model.recordsPositionY
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsPositionY = true;
            }
        }
        ControlPanelButton {
            text: "r"
            gridX: 1; gridY: 1
            checked: myApp.model.recordsRotation && !myApp.model.recordsScale
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsRotation = true;
            }
        }
        ControlPanelButton {
            text: "s"
            gridX: 2; gridY: 1
            checked: !myApp.model.recordsRotation && myApp.model.recordsScale
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsScale = true;
            }
        }
        ControlPanelButton {
            text: "Anchor x"
            gridX: 1; gridY: 2
            checked: myApp.model.recordsAnchorX && !myApp.model.recordsAnchorY
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsAnchorX = true;
            }
        }
        ControlPanelButton {
            text: "Anchor y"
            gridX: 2; gridY: 2
            checked: !myApp.model.recordsAnchorX && myApp.model.recordsAnchorY
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsAnchorY = true;
            }
        }
    }
}
