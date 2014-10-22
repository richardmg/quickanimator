import QtQuick 2.0

Item {
    id: root
    property int menuIndex: 0
    property var menuRows: [playRow, editRow]

    function rotate(down)
    {
        if (down) {
            if (myApp.model.fullScreenMode)
                myApp.model.fullScreenMode = false;
            else
                menuIndex = (menuIndex + 1 === menuRows.length) ? 0 : menuIndex + 1;
        } else {
            myApp.model.fullScreenMode = !myApp.model.fullScreenMode;
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
        opacity: myApp.model.fullScreenMode ? 0 : 0.1
        visible: opacity !== 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }

    PlayMenuRow {
        id: playRow
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
            onClicked: print("Record")
        }
    }

    PlayMenuRow {
        id: editRow
        MultiTouchButton {
            Text { x: 2; y: 2; text: "Undo" }
            onClicked: print("undo")
        }

        MultiTouchButton {
            Text { x: 2; y: 2; text: "Redo" }
            onClicked: print("redo")
        }
    }
}
