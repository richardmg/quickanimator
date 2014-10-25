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

        ProxyButton {
            onClicked: myApp.model.time = 0
            Text { x: 2; y: 2; text: myApp.model.time === 0 ? "Forward" : "Rewind" }
        }

        ProxyButton {
            onClicked: myApp.timeFlickable.userPlay = !myApp.timeFlickable.userPlay
            Text { x: 2; y: 2; text:  myApp.timeFlickable.userPlay ? "Stop" : "Play" }
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Record" }
            onClicked: print("Record")
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Undo" }
            onClicked: print("undo")
        }

        ProxyButton {
            Text { x: 2; y: 2; text: "Redo" }
            onClicked: print("redo")
        }
    }

    FlickableMouseArea {
        anchors.fill: parent

        onMomentumXUpdated: {
            buttonRow.x += momentumX;
            buttonRow.x = (buttonRow.x > parent.width) ? parent.width
                                                       : (buttonRow.x < -buttonRow.width) ? -buttonRow.width
                                                                                          : buttonRow.x;
        }

        onClicked: {
            var p = mapToItem(buttonRow, mouseX, mouseY);
            var button = buttonRow.childAt(p.x, p.y);
            if (button)
                button.clicked();
        }
    }
}
