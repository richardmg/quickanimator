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
            onClicked: myApp.menu.visible = true;
            Text { x: 2; y: 2; text: "Rewind" }
        }
        MultiTouchButton {
            onClicked: menu.visible = true;
            Text { x: 2; y: 2; text: "Play" }
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
