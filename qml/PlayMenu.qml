import QtQuick 2.0

Item {
    id: root
    property int menuIndex: 0
    property var menuRows: [playRow, editRow, emptyRow]

    function rotate(down)
    {
        menuRows[menuIndex].opacity = 0;

        if (++menuIndex === menuRows.length)
            menuIndex = 0;

        menuRows[menuIndex].opacity = 1
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
        opacity: menuIndex !== menuRows.length - 1 ? 0.1 : 0
        visible: opacity !== 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }

    Row {
        id: playRow
        height: parent.height
        width: childrenRect.width
        x: root.width - width
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        MultiTouchButton {
            onClicked: myApp.model.time = 0
            Text { x: 2; y: 2; text: myApp.model.time === 0 ? "Forward" : "Rewind" }
        }

        MultiTouchButton {
            onClicked: myApp.timeline.userPlay = !myApp.timeline.userPlay
            Text { x: 2; y: 2; text:  myApp.timeline.userPlay ? "Stop" : "Play" }
        }

        MultiTouchButton {
            Text { x: 2; y: 2; text: "Record" }
        }
    }

    Row {
        id: editRow
        height: parent.height
        width: childrenRect.width
        x: root.width - width
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        MultiTouchButton {
            Text { x: 2; y: 2; text: "Undo" }
        }

        MultiTouchButton {
            Text { x: 2; y: 2; text: "Redo" }
        }
    }

    Row {
        id: emptyRow
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }
}
