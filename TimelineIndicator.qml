import QtQuick 2.1

Item {
    id: root
    property int index: 0

    Rectangle {
        color: "red"
        x: handle.x + (cellWidth / 2) - 1
        y: cellHeight + 1
        width: 1
        height: parent.height - y - 1
    }

    Rectangle {
        id: handle
        x: (index * cellWidth) + 1
        y: 0
        width: cellWidth - 1
        height: cellHeight
        gradient: Gradient {
            GradientStop {
                position: 0.0;
                color: Qt.rgba(1.0, 0.0, 0.0, 1.0)
            }
            GradientStop {
                position: 1.0;
                color: Qt.rgba(0.8, 0.0, 0.0, 1.0)
            }
        }
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

