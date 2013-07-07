import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property alias timelineCanvas: timelineCanvas
    property alias selectedX: timelineCanvas.selectedX
    property alias selectedY: timelineCanvas.selectedY
    property var model
    
    signal clicked
    signal doubleClicked

    clip: true

    TimelineCanvas {
        id: timelineCanvas
        anchors.fill: parent
        model: root.model
        onClicked: root.clicked()
        onDoubleClicked: root.doubleClicked()
    }

    Rectangle {
        id: selectorLine
        color: Qt.darker(myApp.style.accent, 1.3);
        x: (timelineCanvas.selectedX * timelineCanvas.cellWidth) + (timelineCanvas.cellWidth / 2) - 1
        width: 1
        height: parent.height - y
    }

    Rectangle {
        id: selectorHandle
        x: 1 + (timelineCanvas.selectedX * timelineCanvas.cellWidth)
        y: -timelineCanvas.flickable.contentY + (timelineCanvas.selectedY * myApp.style.cellHeight)
        z: 10
        width: timelineCanvas.cellWidth - 2
        height: myApp.style.cellHeight - 1
        gradient: Gradient {
            GradientStop {
                position: 0.0;
                color: Qt.rgba(0.9, 0.9, 0.9, 1.0)
            }
            GradientStop {
                position: 1.0;
                color: Qt.rgba(0.8, 0.8, 0.8, 1.0)
            }
        }
    }
}

