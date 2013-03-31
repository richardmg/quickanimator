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
    
    color: palette.base
    clip: true

    StoryBoardGridView {
        x: border.width
        y: cellHeight + border.width
        width: root.width - (border.width * 2)
        height: root.height - y - border.width
    }

    TitleBar {
        title: "0.0s"
    }

    StoryBoardTimeBar {
        anchors.fill: parent
        index: 20
    }

}

