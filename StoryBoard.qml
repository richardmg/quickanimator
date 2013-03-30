import QtQuick 2.1

Flickable {
    id: root
    
    property int cellHeight: 20
    property int cellWidth: 10

    contentWidth: 1000
    contentHeight: 1000

    StoryBoardGrid {
        y: cellHeight
        width: root.contentWidth
        height: root.contentHeight - y
    }

    StoryBoardTimeBar {
        width: root.contentWidth
        height: contentHeight
        index: 20
    }
}

