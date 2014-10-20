import QtQuick 2.0

Item {
    width: childrenRect.width
    height: childrenRect.height

    Row {
        spacing: 1
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
