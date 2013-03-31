import QtQuick 2.1

Item {
    id: root
    
    property int cellHeight: 20
    property int cellWidth: 10
    property int rows: 1
    property int columns: 20

    SystemPalette {
        id: palette
    }
    
//    color: "green"//palette.base
    clip: true

    StoryBoardGridView {
        y: cellHeight
        width: root.width
        height: root.height - y
    }

    TitleBar {
        title: "0.0s"
    }

    StoryBoardTimeBar {
        anchors.fill: parent
        index: 20
    }

}

