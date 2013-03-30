import QtQuick 2.1

Flickable {
    id: root
    
    contentWidth: 1000
    contentHeight: 1000

//    StoryBoardGridView {
//        width: root.contentWidth
//        height: root.contentHeight
//    }

    StoryBoardGrid {
        width: root.contentWidth
        height: root.contentHeight
    }
}

