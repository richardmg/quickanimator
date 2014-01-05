import QtQuick 2.0

Rectangle {
    id: root
    color: myApp.style.dark
//    x: myApp.style.splitViewSpacing

    readonly property Item menuGridRoot: root

    Timer {
        interval: 1
        onTriggered: rootMenu.openMenu(true)
        running: true
    }

    signal closeAllMenus()

    ControlPanelSubMenu {
        id: rootMenu;
        ControlPanelButton {
            text: ">"
            checkable: true
            onClicked: myApp.timeline.togglePlay(checked)
            gridX: 0; gridY: 0
            alwaysVisible: true
        }
        ControlPanelButton {
            text: "<<"
            onClicked: myApp.model.setTime(0);
            gridX: 0; gridY: 1
            alwaysVisible: true
        }
        ControlPanelButton {
            text: "..."
            menu: moreOptions
            gridX: 0; gridY: 2
            alwaysVisible: true
        }
    }

    ControlPanelSubMenu {
        id: moreOptions
        ControlPanelButton {
            id: recordOptionButton
            text: xybutton.text
            menu: recordOption
            gridX: 1; gridY: 2
        }
        ControlPanelButton {
            text: "Keyframe"
            checkable: true
            onCheckedChanged: myApp.keyframeInfo.visible = checked
            gridX: 2; gridY: 2
        }
        ControlPanelButton {
            text: "[ ]"
            gridX: 3; gridY: 2
        }
        ControlPanelButton {
            text: "Sprites"
            onClicked: myApp.addImage("dummy.jpeg")
            gridX: 4; gridY: 2
        }
    }

    ControlPanelSubMenu {
        id: recordOption
        ControlPanelButton {
            id: xybutton
            text: "x & y"
            gridX: 1; gridY: 1
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsPositionX = true;
                myApp.model.recordsPositionY = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "x"
            gridX: 2; gridY: 1
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsPositionX = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "y"
            gridX: 3; gridY: 1
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsPositionY = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "r & s"
            gridX: 1; gridY: 0
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsScale = true;
                myApp.model.recordsRotation = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "r"
            gridX: 2; gridY: 0
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsRotation = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "s"
            gridX: 3; gridY: 0
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsScale = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "Anchor\nx & y"
            gridX: 1; gridY: -1
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsAnchorX = true;
                myApp.model.recordsAnchorY = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "Anchor x"
            gridX: 2; gridY: -1
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsAnchorX = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "Anchor y"
            gridX: 3; gridY: -1
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsAnchorY = true;
                recordOptionButton.text = text;
            }
        }
    }
}
