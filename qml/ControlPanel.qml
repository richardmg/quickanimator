import QtQuick 2.0

Rectangle {
    color: myApp.style.dark

    Grid {
        spacing: 5
        x: myApp.style.splitViewSpacing
        width: childrenRect.width + myApp.style.splitViewSpacing
        height: childrenRect.height + myApp.style.splitViewSpacing
        columns: 3

        ControlPanelButton {
            id: recordOptionButton
            text: "x/y"
            menu: recordOption
        }
        ControlPanelButton {
            text: "Keyframe"
            checkable: true
            onClicked: {
                enabled = false
                myApp.keyframeInfo.visible = checked
            }
        }
        ControlPanelButton {
            text: "[ ]"
        }
        ControlPanelButton {
            text: "<<"
            onClicked: myApp.model.setTime(0);
        }
        ControlPanelButton {
            text: "kfps"
        }
        ControlPanelButton {
            text: "Sprites"
            onClicked: myApp.addImage("dummy.jpeg")
        }
    }

    ControlPanelSubMenu {
        id: recordOption
        ControlPanelButton {
            text: "x/y"
            onClicked: print("clicked:", text)
        }
        ControlPanelButton {
            text: "x"
        }
        ControlPanelButton {
            text: "y"
        }
        ControlPanelButton {
            text: "r / s"
        }
        ControlPanelButton {
            text: "r"
        }
        ControlPanelButton {
            text: "s"
        }
    }
}
