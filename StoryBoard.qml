import QtQuick 2.1

Rectangle {
    id: root
    
    property int cellHeight: 20
    property int cellWidth: 10
    property int rows: 10
    property int columns: 20

    SystemPalette {
        id: palette
    }
    
    color: palette.alternateBase
    border.width: 1
    clip: true

    StoryBoardGridView {
        x: border.width
        y: cellHeight + border.width
        width: root.width - (border.width * 2)
        height: root.height - y - border.width
    }

    Rectangle {
        width: parent.width
        height: cellHeight + 2
        border.width: 1
        color: root.color
    }
    StoryBoardTimeBar {
        anchors.fill: parent
        index: 20
    }


}

