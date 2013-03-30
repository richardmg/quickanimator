import QtQuick 2.1

Flickable {
    id: root
    
    property int cellHeight: 20
    property int cellWidth: 10

    contentWidth: 1000
    contentHeight: 1000

//    StoryBoardGridView {
//        width: root.contentWidth
//        height: root.contentHeight
//    }

    StoryBoardGrid {
        y: cellHeight
        width: root.contentWidth
        height: root.contentHeight - y
    }

    StoryBoardTimeBar {
        x: 100
        height: contentHeight
    }
}

