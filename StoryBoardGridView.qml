import QtQuick 2.1

GridView {
    cellWidth: 10
    cellHeight: 20
    model: Math.floor(width / cellWidth) * Math.floor(height / cellHeight)
    delegate: Rectangle {
        width: GridView.view.cellWidth
        height: GridView.view.cellHeight
        color: "black"
        Rectangle {
            color: "white"
            width: parent.width - 1
            height: parent.height - 1
        }
    }
}

