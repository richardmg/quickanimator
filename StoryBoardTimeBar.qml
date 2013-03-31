import QtQuick 2.1

Item {
    id: root
    property int index: 0

    Rectangle {
        color: "red"
        x: handle.x + (cellWidth / 2) - 1
        y: cellHeight + 2
        width: 1
        height: parent.height - y - 1
    }

//    Rectangle {
//        color: "red"
//        x: handle.x + cellWidth - 3
//        y: cellHeight + 2
//        width: 1
//        height: parent.height - y - 1
//    }

    Rectangle {
        id: handle
        x: (index * cellWidth) + 1
        y: 1
        width: cellWidth - 1
        height: cellHeight
        color: "red"
    }

    MouseArea {
        id: mouseArea
        width: cellWidth
        height: cellHeight
        drag.target: mouseArea
        drag.axis: Drag.XAxis
        drag.minimumX: 0
        drag.maximumX: root.width - cellWidth
        onReleased: x = index * cellWidth
        onXChanged: index = Math.floor(x / cellWidth)
        x: index * cellWidth
    }
}

