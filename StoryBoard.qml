import QtQuick 2.1

Item {
    id: root
    clip: true
    property alias timeline: timeline

    Timeline {
        id: timeline
        y: cellHeight
        width: root.width
        height: root.height - y
        cellHeight: 20
        cellWidth: 10
        rows: 3
        selectedX: 0
        selectedY: 0
    }

    TitleBar {
        title: "0.0s"
    }
}

