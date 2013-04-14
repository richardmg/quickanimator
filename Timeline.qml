import QtQuick 2.1
import QtQuick.Controls 1.0

ListView {
    id: view
    property int cellHeight: 20
    property int cellWidth: 10
    property int rows: 3
    property int selectedX: 0
    property int selectedY: 0
    
    signal clicked
    signal doubleClicked

    model: rows
    clip: true
    delegate: TimelineDelegate {}

    Rectangle {
        id: selectorLine
        color: "red"
        x: (selectedX * cellWidth) + (cellWidth / 2) - 1
        y: 1
        width: 1
        height: parent.height - y
    }

    Rectangle {
        id: selectorHandle
        x: (selectedX * cellWidth)
        y: -timeline.contentY + (selectedY * cellHeight)
        z: 10
        width: cellWidth - 1
        height: cellHeight - 1
        gradient: Gradient {
            GradientStop {
                position: 0.0;
                color: Qt.rgba(1.0, 0.0, 0.0, 1.0)
            }
            GradientStop {
                position: 1.0;
                color: Qt.rgba(0.8, 0.0, 0.0, 1.0)
            }
        }
    }

    function addCell(cellComponent, posX, posY)
    {
        var delegate = getDelegateInstanceAt(posY);
        if (!delegate) {
            console.warn("Error: could not add cell at:", posX, posY);
            return;
        }
        var cell = cellComponent.createObject(delegate);
        cell.x = posX * cellWidth;
        cell.width = cellWidth;
        cell.height = cellHeight;
    }

    function getDelegateInstanceAt(index) {
        for(var i = 0; i < contentItem.children.length; ++i) {
            var item = contentItem.children[i];
            // We have to check for the specific objectName we gave our
            // delegates above, since we also get some items that are not
            // our delegates here.
            if (item.objectName == "timelineDelegate" && item.index2 == index)
                return item;
        }
        return undefined;
    }
  
}

