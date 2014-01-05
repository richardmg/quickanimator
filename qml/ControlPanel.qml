import QtQuick 2.0

Rectangle {
    color: myApp.style.dark

    Grid {
        spacing: 5
        x: myApp.style.splitViewSpacing
        width: childrenRect.width + myApp.style.splitViewSpacing
        height: childrenRect.height + myApp.style.splitViewSpacing
        columns: 1

        ControlPanelButton {
            text: ">"
            checkable: true
            onClicked: myApp.timeline.togglePlay(checked)
        }
//        ControlPanelButton {
//            text: "Keyframe"
//            checkable: true
//            onClicked: {
//                enabled = false
//                myApp.keyframeInfo.visible = checked
//            }
//        }
//        ControlPanelButton {
//            text: "[ ]"
//        }
        ControlPanelButton {
            text: "<<"
            onClicked: myApp.model.setTime(0);
        }
        ControlPanelButton {
            text: "..."
            menu: moreOptions
//            onClicked: myApp.model.setTime(0);
        }
//        ControlPanelButton {
//            text: "kfps"
//            onPressedChanged: myApp.msPerFrameFlickable.enabled = pressed
//        }
    }

    ControlPanelSubMenu {
        id: moreOptions
        ControlPanelButton {
            id: recordOptionButton
            text: xybutton.text
            menu: recordOption
        }
        ControlPanelButton {
            text: "Keyframe"
            checkable: true
            onCheckedChanged: myApp.keyframeInfo.visible = checked
        }
        ControlPanelButton {
            text: "[ ]"
        }
        ControlPanelButton {
            text: "Sprites"
            onClicked: myApp.addImage("dummy.jpeg")
        }
    }

    ControlPanelSubMenu {
        id: recordOption
        ControlPanelButton {
            text: "Anchor\nx & y"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsAnchorX = true;
                myApp.model.recordsAnchorY = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "Anchor x"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsAnchorX = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "Anchor y"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsAnchorY = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "r & s"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsScale = true;
                myApp.model.recordsRotation = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "r"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsRotation = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "s"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsScale = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            id: xybutton
            text: "x & y"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsPositionX = true;
                myApp.model.recordsPositionY = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "x"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsPositionX = true;
                recordOptionButton.text = text;
            }
        }
        ControlPanelButton {
            text: "y"
            onClicked: {
                myApp.model.clearRecordState();
                myApp.model.recordsPositionY = true;
                recordOptionButton.text = text;
            }
        }
    }
}
