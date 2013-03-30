import QtQuick 2.1

Rectangle {
    id: root
    
    property int cellHeight: 20
    property int cellWidth: 10
    property int rows: 50
    property int columns: 20

    border.width: 2

    StoryBoardGrid {
        y: cellHeight
        width: root.width
        height: root.height - y
    }

    StoryBoardTimeBar {
        anchors.fill: parent
        index: 20
    }

//    Rectangle {
//        width: parent.width
//        height: cellHeight
//        border.width: 2
//        color: Qt.rgba(0, 0, 0, 0)
//    }
}

