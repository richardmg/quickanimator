import QtQuick 2.0

Rectangle {
    color: myApp.style.dark

    Grid {
        spacing: 5
        x: spacing * 2
        y: spacing * 2
        width: childrenRect.width + (x * 2)
        height: childrenRect.height + (y * 2)
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
