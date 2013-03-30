import QtQuick 2.1

ListView {
    id: view
    model: rows
    clip: true
    delegate: Rectangle {
        width: view.width
        height: cellHeight
        color: "black"
        property int i: index
        Rectangle {
            y: i == 0 ? 1 : 0
            width: parent.width
            height: parent.height - y - 1
            color: "white"
        }
    }
}

