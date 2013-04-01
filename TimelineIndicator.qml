import QtQuick 2.1

Item {
    id: root

    Rectangle {
        id: line
        color: "red"
        x: handle.x + (cellWidth / 2) - 1
        y: 1
        width: 1
        height: parent.height - y
    }

    Rectangle {
        id: handle
        x: (selectedX * cellWidth)
        y: (selectedY * cellHeight) + 1
        width: cellWidth - 1
        height: cellHeight - 2
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
        onReleased: x = selectedX * cellWidth
        onXChanged: selectedX = Math.floor(x / cellWidth)
        x: selectedX * cellWidth
    }
}

