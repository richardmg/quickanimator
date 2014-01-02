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
            text: "x/y"
        }
        ControlPanelButton {
            text: "Keyframe"
            checkable: true
            onClicked: myApp.keyframeInfo.visible = checked
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
}
