import QtQuick 2.0

Item {
    id: root
    property int menuIndex: 0

    function rotate(down)
    {
        if (++menuIndex === 3)
            menuIndex = 0;
        buttonRow.visible = !buttonRow.visible
        background.opacity = (menuIndex === 2) ? 0 : 0.1
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
        opacity: 0.1
        visible: opacity !== 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }

    Row {
        id: buttonRow
        height: parent.height
        width: childrenRect.width
        x: root.width - width

        MultiTouchButton {
            Text { x: 2; y: 2; text: "Undo" }
        }

        MultiTouchButton {
            onClicked: myApp.model.time = 0
            Text { x: 2; y: 2; text: myApp.model.time === 0 ? "Forward" : "Rewind" }
        }

        MultiTouchButton {
            onClicked: myApp.timeline.userPlay = !myApp.timeline.userPlay
            Text { x: 2; y: 2; text:  myApp.timeline.userPlay ? "Stop" : "Play" }
        }

        MultiTouchButton {
            onClicked: menu.visible = true;
            Text { x: 2; y: 2; text: "Record" }
        }

        MultiTouchButton {
            onClicked: menu.visible = true;
            Text { x: 2; y: 2; text: "Menu" }
        }
    }
}
