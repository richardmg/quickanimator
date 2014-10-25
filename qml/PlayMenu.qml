import QtQuick 2.0

Item {
    id: root

    Rectangle {
        id: background
        anchors.fill: parent
        color: "black"
        opacity: myApp.model.fullScreenMode || buttonRow.x >= width || buttonRow.x <= -buttonRow.width ? 0 : 0.3
        visible: opacity !== 0
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    }

    Row {
        id: buttonRow
        width: childrenRect.width
        height: parent.height
        x: parent.width - width

        MultiTouchButton {
            onClicked: myApp.model.time = 0
            Text { x: 2; y: 2; text: myApp.model.time === 0 ? "Forward" : "Rewind" }
        }

        MultiTouchButton {
            onClicked: myApp.timeFlickable.userPlay = !myApp.timeFlickable.userPlay
            Text { x: 2; y: 2; text:  myApp.timeFlickable.userPlay ? "Stop" : "Play" }
        }

        MultiTouchButton {
            Text { x: 2; y: 2; text: "Record" }
            onClicked: print("Record")
        }

        MultiTouchButton {
            Text { x: 2; y: 2; text: "Undo" }
            onClicked: print("undo")
        }

        MultiTouchButton {
            Text { x: 2; y: 2; text: "Redo" }
            onClicked: print("redo")
        }
    }

    FlickableMouseArea {
        anchors.fill: parent

        onMomentumXChanged: {
            buttonRow.x += momentumX;
            buttonRow.x = (buttonRow.x > parent.width) ? parent.width
                                                       : (buttonRow.x < -buttonRow.width) ? -buttonRow.width
                                                                                          : buttonRow.x;
        }
    }
}
