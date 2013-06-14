import QtQuick 2.1
import QtQuick.Controls 1.0

Item {
    id: root

    property alias timelineList: timelineList
    property alias selectedX: timelineList.selectedX
    property alias selectedY: timelineList.selectedY
    property var model
    
    signal clicked
    signal doubleClicked

    clip: true

    TimelineList {
        id: timelineList
        anchors.fill: parent
        model: root.model
        onClicked: root.clicked()
        onDoubleClicked: root.doubleClicked()
    }

    Rectangle {
        id: selectorLine
        color: Qt.darker(myApp.accent, 1.3);
        x: (timelineList.selectedX * timelineList.cellWidth) + (timelineList.cellWidth / 2) - 1
        width: 1
        height: parent.height - y
    }

    Rectangle {
        id: selectorHandle
        x: 1 + (timelineList.selectedX * timelineList.cellWidth)
        y: -timelineList.flickable.contentY + (timelineList.selectedY * timelineList.cellHeight)
        z: 10
        width: timelineList.cellWidth - 2
        height: timelineList.cellHeight - 1
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

