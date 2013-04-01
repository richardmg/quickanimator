import QtQuick 2.1

Item {
    id: root
    
    property int cellHeight: 20
    property int cellWidth: 10
    property int rows: 1
    property int columns: 20
    property int selectedX: 0
    property int selectedY: 0

    clip: true

    SystemPalette {
        id: palette
    }
    
    Timeline {
        id: timeline
        y: cellHeight
        width: root.width
        height: root.height - y

        TimelineIndicator {
            anchors.fill: parent
        }
    }

    TitleBar {
        title: "0.0s"
    }

}

