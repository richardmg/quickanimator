import QtQuick 2.1
import QtQuick.Controls 1.0

Rectangle {
    id: root
    width: view.width
    height: cellHeight
    color: "black"

    property int i: index
    Rectangle {
        y: i == 0 ? 1 : 0
        width: parent.width
        height: parent.height - y - 1
        color: "white"
    }

    MouseArea {
        anchors.fill: parent
        property int supressFlickable:0
        onPressed: supressFlickable = 2
        onReleased: root.ListView.view.interactive = true
        onMouseXChanged: {
            var newSelectedX = Math.max(0, Math.floor(mouseX / cellWidth))
            if (newSelectedX != selectedX) {
                selectedX = newSelectedX
                if (--supressFlickable === 0)
                    root.ListView.view.interactive = false
            }
            selectedY = index
        }
    }

    ToolButton {
        text: "+"
        x: 2
        height: parent.height - 4
        anchors.verticalCenter: parent.verticalCenter
        onClicked: window.addImage("dummy.jpeg") 
    }
}

